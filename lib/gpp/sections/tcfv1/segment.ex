defmodule Gpp.Sections.Tcfv1.Segment do
  @moduledoc false
  alias Gpp.Sections.Tcf
  alias Gpp.Sections.Tcf.{VendorList, DecodeError}
  alias Gpp.BitUtil

  # Full field list with lengths.
  # We are only interested in cmp_id & vendor_consents, so we skip the rest of the fields
  #
  # :created, 36
  # :last_updated, 36
  # :cmp_id, 12
  # :cmp_version, 12
  # :consent_screen, 6
  # :consent_language, 12
  # :vendor_list_version, 12
  # :purpose_consents, 24
  # :vendor_consents, 16
  @first_skip_bits 36 + 36
  @second_skip_bits 12 + 6 + 12 + 12 + 24

  def decode(full_string, :core, segment) do
    input = Enum.drop(segment, @first_skip_bits)
    {:ok, cmp_id, second_input} = BitUtil.parse_12bit_int(input)
    vendor_list = Enum.drop(second_input, @second_skip_bits)

    with {:ok, consents, _rest} <- VendorList.decode(vendor_list) do
      {:ok, %Tcf{version: 1, value: full_string, vendor_consents: consents, cmp_id: cmp_id}}
    end
  end

  def decode(type, _segment, _acc) do
    {:error, %DecodeError{message: "unsupported segment type: #{inspect(type)}"}}
  end
end
