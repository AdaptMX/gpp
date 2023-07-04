defmodule Gpp.Sections.UspcoTest do
  use ExUnit.Case, async: true

  alias Gpp.Sections.{Uspco, Usgpc}

  test "example" do
    input = "bSFgmJQA.YAAA"

    assert {:ok,
            %Uspco{
              core: %Uspco.Core{
                version: 27,
                sharing_notice: 1,
                targeted_advertising_opt_out_notice: 2,
                sale_opt_out_notice: 0,
                sale_opt_out: 0,
                targeted_advertising_opt_out: 1,
                sensitive_data_processing: [
                  1,
                  2,
                  0,
                  0,
                  2,
                  1,
                  2
                ],
                known_child_sensitive_data_consents: [
                  0
                ],
                mspa_covered_transaction: 2,
                mspa_opt_out_option_mode: 1,
                mspa_service_provider_mode: 1
              },
              usgpc: %Usgpc{subsection_type: 1, gpc: true},
              value: input
            }} == Uspco.parse(input)
  end

  test "invalid input" do
    assert {:error, %Gpp.BitUtil.InvalidData{message: "failed to base64 decode: \"waaat\""}} =
             Uspco.parse("waaat")
  end
end
