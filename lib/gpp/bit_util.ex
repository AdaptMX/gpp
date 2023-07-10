defmodule Gpp.BitUtil do
  defmodule InvalidData do
    defexception [:message]
  end

  def url_base64_to_bits(input) when is_binary(input) do
    case Base.url_decode64(input, padding: false) do
      {:ok, binary} ->
        {:ok, binary_to_bits(binary)}

      :error ->
        {:error, %InvalidData{message: "failed to base64 decode: #{inspect(input)}"}}
    end
  end

  def url_base64_to_bits([input]) when is_binary(input), do: url_base64_to_bits(input)

  def url_base64_to_bits(invalid) do
    {:error, %InvalidData{message: "failed to base64 decode, got: #{inspect(invalid)}"}}
  end

  def binary_to_bits(binary) do
    for <<x::size(1) <- binary>>, do: x
  end

  def decode_bool([0 | rest]), do: {:ok, false, rest}
  def decode_bool([1 | rest]), do: {:ok, true, rest}

  def decode_bool([val | _]) do
    {:error, %InvalidData{message: "expected 1 or 0, got: #{inspect(val)}"}}
  end

  # TODO: maybe this would be faster with bitwise operations?
  def parse_2bit_int([a, b | rest]) do
    {:ok, 2 * a + b, rest}
  end

  def parse_2bit_int(bits),
    do: {:error, %InvalidData{message: "expected atleast 2 bits, got: #{inspect(bits)}"}}

  def parse_3bit_int([a, b, c | rest]) do
    {:ok, 4 * a + 2 * b + c, rest}
  end

  def parse_3bit_int(bits),
    do: {:error, %InvalidData{message: "expected atleast 3 bits, got: #{inspect(bits)}"}}

  def parse_6bit_int([a, b, c, d, e, f | rest]) do
    {:ok, 32 * a + 16 * b + 8 * c + 4 * d + 2 * e + f, rest}
  end

  def parse_6bit_int(bits),
    do: {:error, %InvalidData{message: "expected atleast 6 bits, got: #{inspect(bits)}"}}

  def parse_12bit_int([a, b, c, d, e, f, g, h, i, j, k, l | rest]) do
    {:ok,
     2048 * a + 1024 * b + 512 * c + 256 * d + 128 * e + 64 * f +
       32 * g + 16 * h + 8 * i + 4 * j + 2 * k + l, rest}
  end

  def parse_12bit_int(bits),
    do: {:error, %InvalidData{message: "expected atleast 12 bits, got: #{inspect(bits)}"}}

  def decode_bit16([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p | rest]) do
    {:ok,
     32768 * a + 16384 * b + 8192 * c + 4096 * d + 2048 * e +
       1024 * f + 512 * g + 256 * h + 128 * i + 64 * j +
       32 * k + 16 * l + 8 * m + 4 * n + 2 * o + p, rest}
  end

  def decode_bit16(bits),
    do: {:error, %InvalidData{message: "expected atleast 16 bits, got: #{inspect(bits)}"}}

  def parse_2bit_int_list(input, n) do
    parse_2bit_int_list(input, n, [])
  end

  defp parse_2bit_int_list(rest, 0, acc), do: {:ok, Enum.reverse(acc), rest}

  defp parse_2bit_int_list(input, n, acc) do
    with {:ok, value, rest} <- parse_2bit_int(input) do
      parse_2bit_int_list(rest, n - 1, [value | acc])
    end
  end
end
