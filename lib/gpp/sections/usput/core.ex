defmodule Gpp.Sections.Usput.Core do
  use Gpp.Decoder,
    version: :int_6bit,
    sharing_notice: :int_2bit,
    sale_opt_out_notice: :int_2bit,
    targeted_advertising_opt_out_notice: :int_2bit,
    sensitive_data_processing_opt_out_notice: :int_2bit,
    sale_opt_out: :int_2bit,
    targeted_advertising_opt_out: :int_2bit,
    sensitive_data_processing: [int_2bit_list: [8]],
    known_child_sensitive_data_consents: :int_2bit,
    mspa_covered_transaction: :int_2bit,
    mspa_opt_out_option_mode: :int_2bit,
    mspa_service_provider_mode: :int_2bit
end
