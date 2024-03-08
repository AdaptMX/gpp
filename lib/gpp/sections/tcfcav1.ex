defmodule Gpp.Sections.Tcfcav1 do
  @moduledoc """
  Based on the EU IAB Transparency and Consent Framework, but with a few fields removed
  and others renamed.

  Only decodes the "version" and the "vendor consents" parts of the "core" segment.
  """
  alias Gpp.BitUtil
  alias Gpp.Sections.Tcf
  @behaviour Gpp.Section

  @type t :: Tcf.t()

  @impl Gpp.Section
  def parse(input) do
    with [core_segment | _] <- String.split(input, ".", parts: 2),
         {:ok, bits} <- BitUtil.url_base64_to_bits(core_segment),
         {:ok, type, _rest} <- Tcf.segment_type(bits),
         {:ok, version, rest} <- Tcf.version(bits),
         {:ok, parsed} <- __MODULE__.Segment.decode(input, type, rest) do
      {:ok, %{parsed | version: version}}
    end
  end
end
