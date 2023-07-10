defmodule Gpp.Section do
  @doc "Parse a section string in to the relevant struct."
  @callback parse(String.t()) :: {:ok, struct()} | {:error, Exception.t()}
end
