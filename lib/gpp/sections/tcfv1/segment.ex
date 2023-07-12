defmodule Gpp.Sections.Tcfv1.Segment do
  @moduledoc false
  alias Gpp.Sections.Tcf
  alias Gpp.Sections.Tcf.{VendorList, DecodeError}

  # Full field list with lengths.
  # We are only interested in vendor_consents, so we skip straight to that field.
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
  @skip_bits 36 + 36 + 12 + 12 + 6 + 12 + 12 + 24

  def decode(full_string, :core, segment) do
    input = Enum.drop(segment, @skip_bits)

    with {:ok, consents, _rest} <- VendorList.decode(input) do
      {:ok, %Tcf{version: 1, value: full_string, vendor_consents: consents}}
    end
  end

  def decode(type, _segment, _acc) do
    {:error, %DecodeError{message: "unsupported segment type: #{inspect(type)}"}}
  end
end
