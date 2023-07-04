defmodule Gpp.Sections.Uspco do
  alias Gpp.Sections.Usgpc
  defstruct [:value, :core, :usgpc, section_id: 10]

  def parse(input) do
    [core | usgpc] = String.split(input, ".")

    with {:ok, core} <- __MODULE__.Core.parse(core),
         {:ok, usgpc} <- Usgpc.parse(usgpc) do
      {:ok, %__MODULE__{value: input, core: core, usgpc: usgpc}}
    end
  end
end
