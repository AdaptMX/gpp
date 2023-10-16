defmodule Gpp.Section do
  @type input :: String.t()

  @doc "Parse a section string in to the relevant struct."
  @callback parse(input()) :: {:ok, struct()} | {:error, Exception.t()}
end
