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
      iex> Gpp.FibonacciDecoder.decode([1, 0, 0, 0, 0, 1, 1])
      {:ok, 14}
  """
  def decode(input), do: decode(input, 3, 0)

  defp decode([1], _n, acc), do: {:ok, acc}

  defp decode([invalid], _n, _acc) do
    {:error, %InvalidInputError{message: "unexpected value: #{inspect(invalid)}"}}
  end

  defp decode([1 | rest], n, acc) do
    decode(rest, n + 1, acc + Fibonacci.calc(n))
  end

  defp decode([0 | rest], n, acc) do
    decode(rest, n + 1, acc)
  end

  defp decode([invalid | _], _, _) do
    {:error, %InvalidInputError{message: "unexpected value: #{inspect(invalid)}"}}
  end
end
