# defmodule Gpp.Sections.Tcfv2 do
#   alias Gpp.BitUtil
#   alias Gpp.Sections.Tcf
#   alias Gpp.Sections.Tcfv2.Segment
#
#   def parse(input) do
#     with [core_segment | _] <- String.split(input, ".", parts: 2),
#          {:ok, decoded} <- BitUtil.url_base64_to_bits(core_segment),
#          {:ok, type, _rest} <- segment_type(decoded) do
#       Segment.decode(type, decoded, %Tcf{})
#     end
#   end
#
#   defp segment_type(bits) do
#     with {:ok, type_int, rest} <- BitUtil.parse_3bit_int(bits),
#          {:ok, type} <- Tcf.SegmentId.to_name(type_int) do
#       {:ok, type, rest}
#     end
#   end
# end
