defmodule Gpp.Sections.Usput do
  defstruct [:value, :core, section_id: 12]

  def parse(input) do
    with {:ok, core} <- __MODULE__.Core.parse(input) do
      {:ok, %__MODULE__{value: input, core: core}}
    end
  end
end
