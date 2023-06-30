defmodule Gpp do
  @moduledoc """
  IAB Global Privacy Platform

  [Spec](https://github.com/InteractiveAdvertisingBureau/Global-Privacy-Platform)
  [Golang Implementation](https://github.com/prebid/go-gpp)
  """
  alias Gpp.{SectionRange, IdRange, FibonacciDecoder}

  defstruct [:type, :version, section_range: 0, sections: []]

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

  def decode(input) do
    [header | sections] = String.split(input, "~")

    # TODO: This padding and then slicing logic is necessary for base64 decoding,
    # but there should be a way around this...
    length = byte_size(header)
    required_length = length + (6 - rem(length, 6))
    padded = String.pad_trailing(header, required_length, "0")
    decoded_length = decoded_length(input)

    padded
    |> Base.url_decode64!(padding: false)
    |> String.slice(0..(decoded_length - 1))
    |> then(fn b ->
      for <<x::size(1) <- b>>, do: x
    end)
    |> parse_sections(sections)
  end

  defp parse_sections(bits, sections) do
    with {:ok, type, version_and_section_range} <- type(bits),
         {:ok, version, rest} <- version(version_and_section_range),
         {:ok, section_range} <- section_range(rest),
         {:ok, sections} <- sections(section_range, sections) do
      %__MODULE__{
        type: type,
        version: version,
        section_range: section_range,
        sections: sections
      }
    end
  end

  # https://cs.opensource.google/go/go/+/refs/heads/master:src/encoding/base64/base64.go;l=623;drc=79d4defa75a26dd975c6ba3ac938e0e414dfd3e9?q=RawURLEncoding&ss=go%2Fgo:src%2Fencoding%2Fbase64%2F
  defp decoded_length(binary), do: (byte_size(binary) * 6) |> div(4)

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

  defp decode_fibonacci_range(count, input, acc \\ %SectionRange{})

  defp decode_fibonacci_range(0, rest, acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp decode_fibonacci_range(count, [next_bit | input], acc) do
    if next_bit == 0 do
      {offset, rest} = decode_fibonacci_word(input)
      entry = acc.max + offset
      id_range = %IdRange{start_id: entry, end_id: entry}
      acc = %{acc | max: max(entry, acc.max), range: [id_range | acc.range]}
      decode_fibonacci_range(count - 1, rest, acc)
    else
      # https://github.com/prebid/go-gpp/blob/main/util/fibonacci.go#L79
      {offset, rest} = decode_fibonacci_word(input)
      entry = acc.max + offset
      id_range = %IdRange{start_id: entry, end_id: entry}
      acc = %{acc | max: max(entry, acc.max), range: [id_range | acc.range]}
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

  defp sections(section_count, input) do
    acc = input
    # {_, acc} =
    #   Enum.reduce(1..section_count, {input, []}, fn _, {input, acc} ->
    #     IO.inspect(input)
    #     {input, acc}
    #   end)

    {:ok, acc}
  end

  def decode_int6([a, b, c, d, e, f]) do
    32 * a + 16 * b + 8 * c + 4 * d + 2 * e + f
  end

  def decode_int12([a, b, c, d, e, f, g, h, i, j, k, l]) do
    2048 * a + 1024 * b + 512 * c + 256 * d + 128 * e + 64 * f +
      32 * g + 16 * h + 8 * i + 4 * j + 2 * k + l
  end
end
