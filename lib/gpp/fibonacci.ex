defmodule Gpp.Fibonacci do
  @moduledoc """
  Precomputed (compile-time) Fibonacci sequence, which provides super fast
  runtime lookups of the precomputed values.

      iex> for i <- 1..20, do: Gpp.Fibonacci.calc(i)
      [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181]

      iex> Gpp.Fibonacci.calc(123)
      14028366653498915298923761
  """
  defmodule Hack do
    @moduledoc false
    def calc(0), do: 0
    def calc(1), do: 1
    def calc(n), do: calc(0, 1, n - 2)

    def calc(_, prv, -1), do: prv

    def calc(prvprv, prv, n) do
      next = prv + prvprv
      calc(prv, next, n - 1)
    end
  end

  for n <- 1..1_000 do
    def calc(unquote(n)), do: unquote(Hack.calc(n - 1))
  end

  # if we are hitting this clause we should increase the range above
  def calc(n), do: Hack.calc(n)
end
