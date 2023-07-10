defmodule Gpp.Sections.Usp do
  alias Gpp.Sections.Usgpc

  defmacro __using__(opts) do
    section_id = Keyword.fetch!(opts, :section_id)
    usgpc? = Keyword.get(opts, :usgpc?, false)

    fields =
      [:value, :core, section_id: section_id]
      |> then(fn list ->
        if usgpc? do
          [:usgpc | list]
        else
          list
        end
      end)

    if usgpc? do
      quote bind_quoted: [fields: fields] do
        alias Gpp.Sections.Usp
        @behaviour Gpp.Section

        @type t :: %__MODULE__{
                value: String.t(),
                core: __MODULE__.Core.t(),
                section_id: Gpp.section_id(),
                usgpc: Usgpc.t()
              }
        defstruct fields

        @impl Gpp.Section
        def parse(input), do: Usp.parse_with_usgpc(__MODULE__, __MODULE__.Core, input)
      end
    else
      quote bind_quoted: [fields: fields] do
        alias Gpp.Sections.Usp
        @behaviour Gpp.Section

        @type t :: %__MODULE__{
                value: String.t(),
                core: __MODULE__.Core.t(),
                section_id: Gpp.section_id()
              }
        defstruct fields

        @impl Gpp.Section
        def parse(input), do: Usp.parse(__MODULE__, __MODULE__.Core, input)
      end
    end
  end

  def parse_with_usgpc(module, core_module, input) do
    [core | usgpc] = String.split(input, ".", parts: 2)

    with {:ok, core} <- core_module.parse(core),
         {:ok, usgpc} <- parse_usgpc(usgpc) do
      {:ok, struct(module, value: input, core: core, usgpc: usgpc)}
    end
  end

  def parse(module, core_module, input) do
    with {:ok, core} <- core_module.parse(input) do
      {:ok, struct(module, value: input, core: core)}
    end
  end

  defp parse_usgpc([input]) when byte_size(input) == 4 do
    Usgpc.parse(input)
  end

  defp parse_usgpc(_), do: {:ok, nil}
end
