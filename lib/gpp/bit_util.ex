defmodule Gpp.BitUtil do
  def url_base64_to_bits(input) do
    with {:ok, binary} <- Base.url_decode64(input, padding: false) do
      {:ok, binary_to_bits(binary)}
    end
  end

  def binary_to_bits(binary) do
    for <<x::size(1) <- binary>>, do: x
  end

  def decode_bool([0 | rest]), do: {false, rest}
  def decode_bool([1 | rest]), do: {true, rest}

  # TODO: maybe this would be faster with bitwise operations?
  def decode_bit2([a, b | rest]) do
    {2 * a + b, rest}
  end

  def decode_bit6([a, b, c, d, e, f | rest]) do
    {32 * a + 16 * b + 8 * c + 4 * d + 2 * e + f, rest}
  end

  def decode_bit12([a, b, c, d, e, f, g, h, i, j, k, l | rest]) do
    {2048 * a + 1024 * b + 512 * c + 256 * d + 128 * e + 64 * f +
       32 * g + 16 * h + 8 * i + 4 * j + 2 * k + l, rest}
  end

  def decode_bit2_list(input, n) do
    decode_bit2_list(input, n, [])
  end

  defp decode_bit2_list(rest, 0, acc), do: {Enum.reverse(acc), rest}

  defp decode_bit2_list(input, n, acc) do
    {value, rest} = decode_bit2(input)
    decode_bit2_list(rest, n - 1, [value | acc])
  end
end
