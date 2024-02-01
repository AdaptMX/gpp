defmodule Gpp.Sections.Tcfv2.Segment do
  @moduledoc false
  alias Gpp.Sections.Tcf
  alias Gpp.Sections.Tcf.{Segment, DecodeError}

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
  # :tcf_policy_version, 6
  # :is_service_specific, 1
  # :use_non_standard_stacks, 1
  # :special_feature_opt_ins, 12
  # :purpose_consents, 24
  # :publisher_legitimate_interests, 24
  # :purpose_one_treatment, 1
  # :publisher_country_code, 12
  # :vendor_consents, 16
  # :vendor_legitimate_interests, 12
  # :publisher_restrictions
  @first_skip_bits 36 + 36
  @second_skip_bits 12 + 6 + 12 + 12 + 6 + 1 + 1 + 12 + 24 + 24 + 1 + 12

  def decode(full_string, :core, segment) do
    with {:ok, cmp_id, consents} <-
           Segment.decode_fields(segment, @first_skip_bits, @second_skip_bits) do
      {:ok, %Tcf{version: 2, value: full_string, vendor_consents: consents, cmp_id: cmp_id}}
    end
  end

  def decode(type, _segment, _acc) do
    {:error, %DecodeError{message: "unsupported segment type: #{inspect(type)}"}}
  end
end
