defmodule Gpp.Sections.Tcf.Segment do
  alias Gpp.BitUtil
  alias Gpp.Sections.Tcf.VendorList

  @doc """
  Decodes the fields of a TCF segment. Currently only returns for cmp_id and vendor_consents.
  """
  def decode_fields(segment, first_skip_bits, second_skip_bits) do
    dbg segment

    with {:ok, cmp_id, second_input} <-
           Enum.drop(segment, first_skip_bits) |> BitUtil.parse_12bit_int(),
         vendor_list <- Enum.drop(second_input, second_skip_bits),
         {:ok, consents, _rest} <- VendorList.decode(vendor_list) do
      {:ok, cmp_id, consents}
    end
  end
end
