defmodule Gpp.Sections.Uspv1 do
  defstruct [:value, id: 6]

  def parse(input), do: {:ok, %__MODULE__{value: input}}
end
