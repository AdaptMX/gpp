defmodule Gpp do
  @moduledoc """
  IAB Global Privacy Platform

  [Spec](https://github.com/biteractiveAdvertisingBureau/Global-Privacy-Platform)
  [Golang Implementation](https://github.com/prebid/go-gpp)
  """
  alias Gpp.{Sections, SectionRange, IdRange, FibonacciDecoder, BitUtil}

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

  defmodule DeprecatedSection do
    defexception [:id, message: "has been deprecated"]
  end

  @min_header_length 3

  @sections %{
    2 => "tcfeu2",
    3 => "gpp header",
    6 => "uspv1",
    7 => "uspnat",
    8 => "uspca",
    9 => "uspva",
    10 => "uspco",
    11 => "usput",
    12 => "uspct"
  }

  def deprecated(id), do: {:error, %DeprecatedSection{id: id}}

  for {id, name} <- @sections do
    def section_name(unquote(id)), do: unquote(name)
  end

  for {id, name} <- @sections do
    def section_id(unquote(name)), do: unquote(id)
  end

  def parse(input) do
    [header | sections] = String.split(input, "~")

    with :ok <- validate_header_length(header),
         {:ok, header_bits} <- BitUtil.url_base64_to_bits(header),
         {:ok, gpp, section_range} <- parse_header(header_bits) do
      parse_sections(gpp, section_range, sections)
    end
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
    case BitUtil.decode_bit6(input) do
      {:ok, type, rest} when type == 3 ->
        {:ok, type, rest}

      other ->
        {:error, %InvalidType{message: "must equal 3, got #{other}"}}
    end
  end

  defp version(input) do
    with {:ok, version, rest} <- BitUtil.decode_bit6(input) do
      {:ok, version, rest}
    end
  end

  defp section_range(input), do: decode_section_range(input)

  defp decode_section_range(input) do
    with {:ok, section_count, rest} <- BitUtil.decode_bit12(input) do
      decode_fibonacci_range(section_count, rest)
    end
  end

  defp decode_fibonacci_range(count, input) do
    decode_fibonacci_range(count, input, %SectionRange{size: count})
  end

  defp decode_fibonacci_range(0, _rest, %{range: range} = acc) do
    {:ok, %{acc | range: Enum.reverse(range)}}
  end

  defp decode_fibonacci_range(count, [next_bit | input], acc) do
    if next_bit == 0 do
      {offset, rest} = decode_fibonacci_word(input)
      entry = acc.max + offset
      id_range = %IdRange{start_id: entry, end_id: entry}
      acc = %{acc | max: max(entry, acc.max), range: [id_range | acc.range]}
      decode_fibonacci_range(count - 1, rest, acc)
    else
      {offset, rest} = decode_fibonacci_word(input)
      {second_offset, rest} = decode_fibonacci_word(rest)
      start_id = acc.max + offset
      end_id = start_id + second_offset
      id_range = %IdRange{start_id: start_id, end_id: end_id}
      acc = %{acc | max: max(end_id, acc.max), range: [id_range | acc.range]}
      decode_fibonacci_range(count - 1, rest, acc)
    end
  end

  defp decode_fibonacci_word(input, acc \\ [])
  defp decode_fibonacci_word([], acc), do: {:ok, Enum.reverse(acc)}

  # fibonacci code words are variable length, but always end in 1,1
  defp decode_fibonacci_word([1, 1 | rest], acc) do
    next =
      [1, 1 | acc]
      |> Enum.reverse()
      |> FibonacciDecoder.decode!()

    {next, rest}
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
          parsed
        else
          {:error, error} -> error
        end
      end)

    {:ok, section_ids, sections}
  end

  defp parser(2), do: {:ok, &Sections.Tcfv2.parse/1}
  defp parser(6), do: {:ok, &Sections.Uspv1.parse/1}
  defp parser(7), do: {:ok, &Sections.Uspnat.parse/1}
  defp parser(8), do: {:ok, &Sections.Uspca.parse/1}
  defp parser(9), do: {:ok, &Sections.Uspva.parse/1}
  defp parser(10), do: {:ok, &Sections.Uspco.parse/1}
  defp parser(11), do: {:ok, &Sections.Usput.parse/1}
  defp parser(12), do: {:ok, &Sections.Uspct.parse/1}
  defp parser(id), do: {:error, %DeprecatedSection{id: id}}
end
