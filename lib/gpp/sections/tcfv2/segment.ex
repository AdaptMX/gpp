defmodule Gpp.Sections.Tcfv2.Segment do
  @moduledoc false
  alias Gpp.BitUtil
  alias Gpp.Sections.Tcfv2.{VendorList, DecodeError}

  @segments %{
    0 => :core,
    1 => :vendors_disclosed,
    2 => :vendors_allowed,
    3 => :publisher_tc
  }

  # full field list with lengths
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
  @skip_bits 207

  @v2_core_fields [
    :vendor_consents
  ]

  for {id, segment} <- @segments do
    def id_to_segment(unquote(id)), do: {:ok, unquote(segment)}
    def segment_to_id(unquote(segment)), do: {:ok, unquote(id)}
  end

  def id_to_segment(_), do: {:error, %DecodeError{message: "unknown segment type"}}
  def segment_to_id(_), do: {:error, %DecodeError{message: "unknown segment type"}}

  def decode_segment(:core, segment, acc) do
    with {:ok, acc, rest} <- version(segment, acc),
         {:ok, _field_sequence} <- field_sequence(acc),
         # skip the fields we aren't interested in
         input = Enum.drop(rest, @skip_bits),
         {:ok, acc, _rest} <- decode_vendor_consents(input, acc) do
      {:ok, acc}
    end
  end

  def decode_segment(_type, _segment, _acc) do
    {:error, %DecodeError{message: "unsupported segment type"}}
  end

  defp field_sequence(%{version: 1}), do: {:error, %DecodeError{message: "got TCF v1"}}
  defp field_sequence(%{version: 2}), do: {:ok, @v2_core_fields}

  defp field_sequence(%{version: version}) do
    {:error, %DecodeError{message: "unsupported version #{version}"}}
  end

  defp version(input, acc) do
    with {:ok, version, rest} <- BitUtil.decode_bit6(input) do
      {:ok, %{acc | version: version}, rest}
    end
  end

  defp decode_vendor_consents(segment, acc) do
    with {:ok, vendor_consents, rest} <- VendorList.decode(segment) do
      {:ok, %{acc | vendor_consents: vendor_consents}, rest}
    end
  end
end
