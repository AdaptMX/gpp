defmodule Gpp.BitUtilTest do
  use ExUnit.Case, async: true
  alias Gpp.BitUtil

  @test_binary <<0x04, 0xA2, 0x03, 0xB1, 0x00, 0x2B>>
  @test_bits BitUtil.binary_to_bits(@test_binary)

  describe "decode_bit2/1" do
    test "examples" do
      assert {:ok, 2, []} == BitUtil.decode_bit2(Enum.slice(@test_bits, 31..32))
      assert {:ok, 3, []} == BitUtil.decode_bit2(Enum.slice(@test_bits, 23..24))
      assert {:ok, 1, []} == BitUtil.decode_bit2(Enum.slice(@test_bits, 9..10))
    end
  end

  describe "decode_bit6/1" do
    test "examples" do
      assert {:ok, 29, []} == BitUtil.decode_bit6(Enum.slice(@test_bits, 21..26))
      assert {:ok, 8, []} == BitUtil.decode_bit6(Enum.slice(@test_bits, 12..17))
      assert {:ok, 10, []} == BitUtil.decode_bit6(Enum.slice(@test_bits, 6..11))
    end
  end

  describe "url_base64_to_bits" do
    test "examples" do
      tests = [
        {"DBABMA",
         [
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0
         ]},
        {"DBACNYA",
         [
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           1,
           1,
           0,
           1,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0
         ]},
        {"DBABjw",
         [
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           1,
           1,
           1,
           1
         ]},
        {"DBABBgA",
         [
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           1,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0
         ]}
      ]

      for {input, expected} <- tests do
        assert {:ok, expected} == BitUtil.url_base64_to_bits(input)
      end
    end
  end
end
