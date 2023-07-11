string = "0000001100001100"
bits = string |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
expected = 780

Gpp.BitUtil.parse_16bit_int(bits) |> IO.inspect()

Benchee.run(%{
  "integer_parse" => fn -> Integer.parse(string, 2) end,
  "bits" => fn -> Gpp.BitUtil.parse_16bit_int(bits) end
})
