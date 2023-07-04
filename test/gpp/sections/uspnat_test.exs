defmodule Gpp.Sections.UspnatTest do
  use ExUnit.Case, async: true

  alias Gpp.Sections.{Uspnat, Usgpc}

  test "example" do
    input = "DSJgmkoZJSY.YAAA"

    assert {:ok,
            %Uspnat{
              core: %Uspnat.Core{
                version: 3,
                sharing_notice: 1,
                sale_opt_out_notice: 0,
                sharing_opt_out_notice: 2,
                sensitive_data_processing_opt_out_notice: 2,
                sensitive_data_limit_use_notice: 1,
                sale_opt_out: 2,
                sharing_opt_out: 0,
                targeted_advertising_opt_out: 0,
                targeted_advertising_opt_out_notice: 0,
                sensitive_data_processing: [
                  2,
                  1,
                  2,
                  2,
                  1,
                  0,
                  2,
                  2,
                  0,
                  1,
                  2,
                  1
                ],
                known_child_sensitive_data_consents: [
                  0,
                  2
                ],
                personal_data_consents: 1,
                mspa_covered_transaction: 1,
                mspa_opt_out_option_mode: 0,
                mspa_service_provider_mode: 2
              },
              usgpc: %Usgpc{subsection_type: 1, gpc: true},
              value: input
            }} == Uspnat.parse(input)
  end
end
