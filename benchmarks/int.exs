string = "0000001100001100"
bits = string |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
expected = 780

Gpp.BitUtil.decode_bit16(bits) |> IO.inspect()

Benchee.run(%{
  "integer_parse" => fn -> Integer.parse(string, 2) end,
  "bits" => fn -> Gpp.BitUtil.decode_bit16(bits) end
})
