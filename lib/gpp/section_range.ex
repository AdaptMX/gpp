defmodule Gpp.SectionRange do
  @moduledoc false
  @type t :: %__MODULE__{
          size: non_neg_integer(),
          max: non_neg_integer(),
          range: [Gpp.IdRange.t()]
        }
  defstruct [:size, max: 0, range: []]
end
