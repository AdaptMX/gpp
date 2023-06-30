defmodule Gpp.Section do
  @type t :: %__MODULE__{
          id: pos_integer(),
          value: String.t()
        }
  defstruct [:id, :value]
end
