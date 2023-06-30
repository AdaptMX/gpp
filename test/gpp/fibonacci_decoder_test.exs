defmodule Gpp.FibonacciDecoderTest do
  use ExUnit.Case, async: true
  alias Gpp.FibonacciDecoder
  doctest Gpp.FibonacciDecoder

  test "examples" do
    examples = [
      {1, [1, 1]},
      {2, [0, 1, 1]},
      {3, [0, 0, 1, 1]},
      {4, [1, 0, 1, 1]},
      {5, [0, 0, 0, 1, 1]},
      {6, [1, 0, 0, 1, 1]},
      {7, [0, 1, 0, 1, 1]},
      {8, [0, 0, 0, 0, 1, 1]},
      {9, [1, 0, 0, 0, 1, 1]},
      {10, [0, 1, 0, 0, 1, 1]},
      {11, [0, 0, 1, 0, 1, 1]},
      {12, [1, 0, 1, 0, 1, 1]},
      {13, [0, 0, 0, 0, 0, 1, 1]}
    ]

    for {expected, input} <- examples do
      assert expected == FibonacciDecoder.decode!(input)
    end
  end

  test "raises exception when unexpected value encountered" do
    assert_raise FibonacciDecoder.InvalidInputError, fn ->
      FibonacciDecoder.decode!([0, 1, 0, 1, 9, 9, 9])
    end

    assert_raise FibonacciDecoder.InvalidInputError, fn ->
      FibonacciDecoder.decode!([0, 1, 0, 1, 2])
    end
  end
end
