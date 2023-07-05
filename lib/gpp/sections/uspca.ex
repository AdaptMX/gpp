defmodule Gpp.Sections.Uspca do
  alias Gpp.Sections.Usgpc
  defstruct [:value, :core, :usgpc, section_id: 8]

  def parse(input) do
    [core | usgpc] = String.split(input, ".", parts: 2)

    with {:ok, core} <- __MODULE__.Core.parse(core),
         {:ok, usgpc} <- parse_usgpc(usgpc) do
      {:ok, %__MODULE__{value: input, core: core, usgpc: usgpc}}
    end
  end

  defp parse_usgpc([input]) when byte_size(input) == 4 do
    Usgpc.parse(input)
  end

  defp parse_usgpc(_), do: {:ok, nil}
end
