defmodule Gpp.Sections.Uspnat.Core do
  use Gpp.Decoder,
    version: :int_6_bit,
    sharing_notice: :int_2_bit,
    sale_opt_out_notice: :int_2_bit,
    sharing_opt_out_notice: :int_2_bit,
    targeted_advertising_opt_out_notice: :int_2_bit,
    sensitive_data_processing_opt_out_notice: :int_2_bit,
    sensitive_data_limit_use_notice: :int_2_bit,
    sale_opt_out: :int_2_bit,
    sharing_opt_out: :int_2_bit,
    targeted_advertising_opt_out: :int_2_bit,
    sensitive_data_processing: [int_2_bit_list: [12]],
    known_child_sensitive_data_consents: [int_2_bit_list: [2]],
    personal_data_consents: :int_2_bit,
    mspa_covered_transaction: :int_2_bit,
    mspa_opt_out_option_mode: :int_2_bit,
    mspa_service_provider_mode: :int_2_bit
end
