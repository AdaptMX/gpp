defmodule Gpp do
  @moduledoc """
  IAB Global Privacy Platform string decoding.

  [Spec](https://github.com/biteractiveAdvertisingBureau/Global-Privacy-Platform)
  """
  alias Gpp.{Sections, SectionRange, IdRange, FibonacciDecoder, BitUtil}
  alias Gpp.Sections.{Uspca, Uspco, Uspct, Usput, Uspv1, Uspva, Uspnat, Tcf}

  @type section ::
          Tcf.t()
          | Uspca.t()
          | Uspco.t()
          | Uspct.t()
          | Usput.t()
          | Uspv1.t()
          | Uspva.t()
          | Uspnat.t()
  @type section_id :: pos_integer()
  @type t :: %__MODULE__{
          type: pos_integer(),
          version: pos_integer(),
          section_ids: [section_id()],
          sections: [section()]
        }

  defstruct type: 3, version: 1, section_ids: [], sections: []

  defmodule InvalidHeader do
    defexception [:message]
  end

  defmodule InvalidType do
    defexception [:message]
  end

  defmodule InvalidVersion do
    defexception [:message]
  end

  defmodule InvalidSectionRange do
    defexception [:message]
  end

  defmodule UnknownSection do
    defexception [:message]
  end

  defmodule DeprecatedSection do
    defexception [:section_id, message: "has been deprecated"]
  end

  @min_header_length 3

  @sections %{
    2 => {"tcfeu2", &Sections.Tcf.parse/1},
    3 => {"gpp header", nil},
    5 => {"tcfcav1", &Sections.Tcf.parse/1},
    6 => {"uspv1", &Sections.Uspv1.parse/1},
    7 => {"uspnat", &Sections.Uspnat.parse/1},
    8 => {"uspca", &Sections.Uspca.parse/1},
    9 => {"uspva", &Sections.Uspva.parse/1},
    10 => {"uspco", &Sections.Uspco.parse/1},
    11 => {"usput", &Sections.Usput.parse/1},
    12 => {"uspct", &Sections.Uspct.parse/1}
  }

  @spec parse(String.t()) :: {:ok, t()} | {:error, Exception.t()}
  def parse(input) when byte_size(input) > 3 do
    [header | sections] = String.split(input, "~")

    with :ok <- validate_header_length(header),
         {:ok, header_bits} <- BitUtil.url_base64_to_bits(header),
         {:ok, gpp, section_range} <- parse_header(header_bits) do
      parse_sections(gpp, section_range, sections)
    end
  end

  def parse(invalid), do: {:error, %InvalidHeader{message: "got: #{inspect(invalid)}"}}

  for {sid, {name, _}} <- @sections do
    def section_id_to_name!(unquote(sid)), do: unquote(name)
    def section_name_to_id!(unquote(name)), do: unquote(sid)
  end

  def section_id_to_name!(unknown) do
    raise UnknownSection, "got id: #{inspect(unknown)}"
  end

  def section_name_to_id!(unknown) do
    raise UnknownSection, "got name: #{inspect(unknown)}"
  end

  defp validate_header_length(header) when byte_size(header) > @min_header_length, do: :ok

  defp validate_header_length(header) do
    {:error,
     %InvalidHeader{
       message: "header must be atleast #{@min_header_length} bytes long, got: #{inspect(header)}"
     }}
  end

  defp parse_header(bits) do
    with {:ok, type, version_and_section_range} <- type(bits),
         {:ok, version, rest} <- version(version_and_section_range),
         {:ok, section_range} <- section_range(rest) do
      {:ok, %__MODULE__{type: type, version: version}, section_range}
    end
  end

  defp parse_sections(gpp, section_range, sections) do
    with {:ok, section_ids, sections} <-
           sections(section_range, sections) do
      {:ok, %{gpp | section_ids: section_ids, sections: sections}}
    end
  end

  defp type(input) do
    case BitUtil.parse_6bit_int(input) do
      {:ok, type, rest} when type == 3 ->
        {:ok, type, rest}

      {:ok, type, _} ->
        {:error, %InvalidType{message: "must equal 3, got #{inspect(type)}"}}

      _ ->
        {:error, %InvalidHeader{message: "got #{inspect(input)}"}}
    end
  end

  defp version(input) do
    with {:ok, version, rest} <- BitUtil.parse_6bit_int(input) do
      {:ok, version, rest}
    end
  end

  defp section_range(input), do: decode_section_range(input)

  defp decode_section_range(input) do
    with {:ok, section_count, rest} <- BitUtil.parse_12bit_int(input) do
      decode_fibonacci_range(section_count, rest)
    end
  end

  defp decode_fibonacci_range(count, input) do
    decode_fibonacci_range(count, input, %SectionRange{size: count})
  end

  defp decode_fibonacci_range(0, _rest, %{range: range} = acc) do
    {:ok, %{acc | range: Enum.reverse(range)}}
  end

  defp decode_fibonacci_range(count, [0 | input], acc) do
    with {:ok, {offset, rest}} <- decode_fibonacci_word(input) do
      entry = acc.max + offset
      id_range = %IdRange{start_id: entry, end_id: entry}
      acc = %{acc | max: max(entry, acc.max), range: [id_range | acc.range]}
      decode_fibonacci_range(count - 1, rest, acc)
    end
  end

  defp decode_fibonacci_range(count, [1 | input], acc) do
    with {:ok, {offset, rest}} <- decode_fibonacci_word(input),
         {:ok, {second_offset, rest}} <- decode_fibonacci_word(rest) do
      start_id = acc.max + offset
      end_id = start_id + second_offset
      id_range = %IdRange{start_id: start_id, end_id: end_id}
      acc = %{acc | max: max(end_id, acc.max), range: [id_range | acc.range]}
      decode_fibonacci_range(count - 1, rest, acc)
    end
  end

  defp decode_fibonacci_word(input, acc \\ [])

  defp decode_fibonacci_word([], acc) do
    {:error, %InvalidSectionRange{message: "got #{inspect(Enum.reverse(acc))}"}}
  end

  # fibonacci code words are variable length, but always end in 1,1
  defp decode_fibonacci_word([1, 1 | rest], acc) do
    full_word = Enum.reverse([1, 1 | acc])

    with {:ok, next} <- FibonacciDecoder.decode(full_word) do
      {:ok, {next, rest}}
    end
  end

  defp decode_fibonacci_word([next | rest], acc), do: decode_fibonacci_word(rest, [next | acc])

  defp sections(section_range, input) do
    section_ids =
      Enum.flat_map(section_range.range, fn %{start_id: start_id, end_id: end_id} ->
        for i <- start_id..end_id, do: i
      end)

    sections =
      Enum.zip_with(input, section_ids, fn value, id ->
        with {:ok, parser} <- parser(id),
             {:ok, parsed} <- parser.(value) do
          %{parsed | section_id: id}
        else
          {:error, error} -> error
        end
      end)

    {:ok, section_ids, sections}
  end

  for {id, {_, fun}} when is_function(fun) <- @sections do
    defp parser(unquote(id)), do: {:ok, unquote(fun)}
  end

  defp parser(id), do: {:error, %DeprecatedSection{section_id: id}}
end
