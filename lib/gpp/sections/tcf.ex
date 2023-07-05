defmodule Gpp.Sections.Tcf do
  @moduledoc """
  IAB Transparency and Consent Framework v1.1 & v2.0 String Decoding.

  Only decodes the "version" and the "vendor consents" parts of the "core" segment.
  """
  alias Gpp.BitUtil
  alias Gpp.Sections.Tcf.DecodeError
  alias Gpp.Sections.{Tcfv1, Tcfv2}

  defstruct [
    :version,
    :vendor_consents
  ]

  def parse(input) do
    with [core_segment | _] <- String.split(input, ".", parts: 2),
         {:ok, bits} <- BitUtil.url_base64_to_bits(core_segment),
         {:ok, type, _rest} <- segment_type(bits),
         {:ok, version, rest} <- version(bits) do
      case version do
        2 -> Tcfv2.Segment.decode(type, rest)
        1 -> Tcfv1.Segment.decode(type, rest)
        other -> {:error, %DecodeError{message: "unknown TCF version: #{other}"}}
      end
    end
  end

  defp segment_type(bits) do
    with {:ok, type_int, rest} <- BitUtil.parse_3bit_int(bits),
         {:ok, type} <- __MODULE__.SegmentId.to_name(type_int) do
      {:ok, type, rest}
    end
  end

  defp version(input), do: BitUtil.parse_6bit_int(input)
end
