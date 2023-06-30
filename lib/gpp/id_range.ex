defmodule Gpp.IdRange do
  @type t :: %__MODULE__{
          start_id: non_neg_integer(),
          end_id: non_neg_integer()
        }
  defstruct [:start_id, :end_id]
end
