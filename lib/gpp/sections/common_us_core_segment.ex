defmodule Gpp.Sections.CommonUsCoreSegment do
  defstruct [
    :version,
    :sharing_notice,
    :sale_opt_out_notice,
    :targeted_advertising_opt_out_notice,
    :sale_opt_out,
    :targeted_advertising_opt_out,
    :sensitive_data_processing,
    :known_child_sensitive_data_consents,
    :mspa_covered_transaction,
    :mspa_opt_out_option_mode,
    :mspa_service_provider_mode
  ]
end
