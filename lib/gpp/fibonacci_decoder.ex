defmodule Gpp.FibonacciDecoder do
  @moduledoc """
  Decode Fibonacci encoded lists of bits in to decimal integers.

  See: https://en.wikipedia.org/wiki/Fibonacci_coding
  """
  alias Gpp.Fibonacci

  defmodule InvalidInputError do
    defexception [:message]
  end

  @doc """
    iex> Gpp.FibonacciDecoder.decode!([1, 0, 0, 0, 0, 1, 1])
    14
  """
  def decode!(input), do: decode!(input, 3, 0)

  defp decode!([1], _n, acc), do: acc

  defp decode!([invalid], _n, _acc) do
    raise InvalidInputError, message: "unexpected value: #{invalid}"
  end

  defp decode!([next | rest], n, acc) do
    acc =
      cond do
        next == 1 ->
          acc + Fibonacci.calc(n)

        next == 0 ->
          acc

        true ->
          raise InvalidInputError, message: "unexpected value: #{next}"
      end

    decode!(rest, n + 1, acc)
  end
end
