defmodule Gpp.Sections.Tcfv2 do
  alias Gpp.BitUtil
  alias Gpp.Sections.Tcfv2.Segment

  defstruct [
    :version,
    :vendor_consents
  ]

  defmodule DecodeError do
    defexception [:message]
  end

  def parse(input) do
    with [core_segment | _] <- String.split(input, ".", parts: 2),
         {:ok, decoded} <- BitUtil.url_base64_to_bits(core_segment),
         {:ok, type, _rest} <- segment_type(decoded) do
      Segment.decode_segment(type, decoded, %__MODULE__{})
    end
  end

  defp segment_type(bits) do
    {type_int, rest} = BitUtil.decode_bit3(bits)

    with {:ok, type} <- Segment.id_to_segment(type_int) do
      {:ok, type, rest}
    end
  end
end
