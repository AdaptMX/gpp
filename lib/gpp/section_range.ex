defmodule Gpp.SectionRange do
  @type t :: %__MODULE__{
          size: non_neg_integer(),
          max: non_neg_integer(),
          range: [Gpp.IdRange.t()]
        }
  defstruct [:size, max: 0, range: []]
end
