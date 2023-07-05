# defmodule Gpp.Sections.Tcfv1 do
#   alias Gpp.BitUtil
#   alias Gpp.Sections.Tcf.SegmentId
#   alias Gpp.Sections.Tcfv1.Segment
#
#   defstruct [
#     :version,
#     :vendor_consents
#   ]
#
#   def parse(input) do
#     with [core_segment | _] <- String.split(input, ".", parts: 2),
#          {:ok, decoded} <- BitUtil.url_base64_to_bits(core_segment),
#          {:ok, type, _rest} <- segment_type(decoded) do
#       Segment.decode_segment(type, decoded, %__MODULE__{})
#     end
#   end
#
#   defp segment_type(bits) do
#     with {:ok, type_int, rest} <- BitUtil.parse_3bit_int(bits),
#          {:ok, type} <- SegmentId.to_name(type_int) do
#       {:ok, type, rest}
#     end
#   end
# end
