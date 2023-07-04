# defmodule Gpp.Sections.Usp do
#   defmacro __using__(opts) do
#     section_id = Keyword.fetch!(opts, :section_id)
#     uspgc? = Keyword.get(opts, :uspgc, true)
#
#     fields =
#       [:value, :core, section_id: section_id]
#       |> then(fn list ->
#         if uspgc? do
#           [:uspgc | list]
#         else
#           list
#         end
#       end)
#
#     if uspgc? do
#       IO.puts("YES")
#       dbg()
#
#       quote bind_quoted: [fields: fields] do
#         var!(fields, Gpp.Sections.Usp)
#         dbg()
#         alias Gpp.Sections.Usgpc
#         defstruct fields
#
#         def parse(input) do
#           dbg(%__MODULE__{})
#           [core, usgpc] = String.split(input, ".")
#
#           with {:ok, core} <- __MODULE__.Core.parse(core),
#                {:ok, usgpc} <- Usgpc.parse(usgpc) do
#             {:ok, %__MODULE__{value: input, core: core, usgpc: usgpc}}
#           end
#         end
#       end
#     else
#       IO.puts("NO")
#
#       quote bind_quoted: [fields: fields] do
#         alias Gpp.Sections.Usgpc
#         defstruct fields
#
#         def parse(input) do
#           with {:ok, core} <- __MODULE__.Core.parse(core) do
#             {:ok, %__MODULE__{value: input, core: core}}
#           end
#         end
#       end
#     end
#   end
# end
