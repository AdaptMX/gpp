defmodule Gpp.Sections.Tcf.SegmentId do
  alias Gpp.Sections.Tcf.DecodeError

  @segments %{
    0 => :core,
    1 => :vendors_disclosed,
    2 => :vendors_allowed,
    3 => :publisher_tc
  }

  for {id, segment} <- @segments do
    def to_name(unquote(id)), do: {:ok, unquote(segment)}
  end

  def to_name(_), do: {:error, %DecodeError{message: "unknown segment type"}}
end
