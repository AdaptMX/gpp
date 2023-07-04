defmodule Gpp.Sections.UsputTest do
  use ExUnit.Case, async: true

  alias Gpp.Sections.Usput

  test "example" do
    input = "bSRYJllA"

    assert {:ok,
            %Usput{
              core: %Usput.Core{
                version: 27,
                sharing_notice: 1,
                sale_opt_out_notice: 0,
                sensitive_data_processing_opt_out_notice: 1,
                sale_opt_out: 0,
                targeted_advertising_opt_out: 1,
                targeted_advertising_opt_out_notice: 2,
                sensitive_data_processing: [
                  1,
                  2,
                  0,
                  0,
                  2,
                  1,
                  2,
                  1
                ],
                known_child_sensitive_data_consents: 1,
                mspa_covered_transaction: 2,
                mspa_opt_out_option_mode: 1,
                mspa_service_provider_mode: 1
              },
              value: input
            }} == Usput.parse(input)
  end
end
