defmodule Gpp do
  @moduledoc """
  IAB Global Privacy Platform

  [Spec](https://github.com/InteractiveAdvertisingBureau/Global-Privacy-Platform)
  [Golang Implementation](https://github.com/prebid/go-gpp)
  """
  alias Gpp.{Section, SectionRange, IdRange, FibonacciDecoder}

  defstruct type: 3, version: 1, section_ids: [], sections: []

  defmodule InvalidType do
    defexception [:message]
  end

  defmodule InvalidVersion do
    defexception [:message]
  end

  defmodule InvalidSectionRange do
    defexception [:message]
  end

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

  for {id, name} <- @sections do
    def section_name(unquote(id)), do: unquote(name)
  end

  def parse(input) do
    [header | sections] = String.split(input, "~")
    header_bits = decode_header!(header)

    with {:ok, gpp, section_range} <- parse_header(header_bits) do
      parse_sections(gpp, section_range, sections)
    end
  end

  defp decode_header!(string) do
    string
    |> Base.url_decode64!(padding: false)
    |> then(fn b ->
      for <<x::size(1) <- b>>, do: x
    end)
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

  defp type([a, b, c, d, e, f | rest]) do
    case decode_int6([a, b, c, d, e, f]) do
      type when type == 3 ->
        {:ok, type, rest}

      other ->
        {:error, %InvalidType{message: "must equal 3, got #{other}"}}
    end
  end

  defp type(invalid) do
    {:error, %InvalidType{message: "got input #{inspect(invalid)}"}}
  end

  defp version([a, b, c, d, e, f | rest]) do
    {:ok, decode_int6([a, b, c, d, e, f]), rest}
  end

  defp version(invalid) do
    {:error, %InvalidVersion{message: "got input #{inspect(invalid)}"}}
  end

  defp section_range(input), do: decode_section_range(input)

  defp decode_section_range([a, b, c, d, e, f, g, h, i, j, k, l | rest]) do
    section_count = decode_int12([a, b, c, d, e, f, g, h, i, j, k, l])
    decode_fibonacci_range(section_count, rest)
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
      Enum.zip_with(input, section_ids, fn value, id -> %Section{id: id, value: value} end)

    {:ok, section_ids, sections}
  end

  def decode_int6([a, b, c, d, e, f]) do
    32 * a + 16 * b + 8 * c + 4 * d + 2 * e + f
  end

  def decode_int12([a, b, c, d, e, f, g, h, i, j, k, l]) do
    2048 * a + 1024 * b + 512 * c + 256 * d + 128 * e + 64 * f +
      32 * g + 16 * h + 8 * i + 4 * j + 2 * k + l
  end
end
