defmodule Gpp.Sections.UspcaTest do
  use ExUnit.Case, async: true

  alias Gpp.Sections.{Uspca, Usgpc}

  test "example" do
    input = "xlgWEYCZAA.YAAA"

    assert {:ok,
            %Uspca{
              core: %Uspca.Core{
                version: 49,
                sale_opt_out_notice: 2,
                sharing_opt_out_notice: 1,
                sensitive_data_limit_use_notice: 1,
                sale_opt_out: 2,
                sharing_opt_out: 0,
                sensitive_data_processing: [
                  0,
                  1,
                  1,
                  2,
                  0,
                  1,
                  0,
                  1,
                  2
                ],
                known_child_sensitive_data_consents: [
                  0,
                  0
                ],
                personal_data_consents: 0,
                mspa_covered_transaction: 2,
                mspa_opt_out_option_mode: 1,
                mspa_service_provider_mode: 2
              },
              usgpc: %Usgpc{subection_type: 1, gpc: true},
              value: input
            }} == Uspca.parse(input)
  end
end
