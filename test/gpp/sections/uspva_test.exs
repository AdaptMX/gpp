defmodule Gpp.Sections.UspvaTest do
  use ExUnit.Case, async: true
  alias Gpp.Sections.Uspva

  test "example" do
    input = "bSFgmiU"

    assert {:ok,
            %Uspva{
              core: %Uspva.Core{
                version: 27,
                sharing_notice: 1,
                sale_opt_out_notice: 0,
                targeted_advertising_opt_out_notice: 2,
                sale_opt_out: 0,
                targeted_advertising_opt_out: 1,
                sensitive_data_processing: [
                  1,
                  2,
                  0,
                  0,
                  2,
                  1,
                  2,
                  2
                ],
                known_child_sensitive_data_consents: [
                  0
                ],
                mspa_covered_transaction: 2,
                mspa_opt_out_option_mode: 1,
                mspa_service_provider_mode: 1
              },
              value: input
            }} == Uspva.parse(input)
  end
end
