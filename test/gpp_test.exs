defmodule GppTest do
  use ExUnit.Case
  doctest Gpp

  test "full gpp strings" do
    examples = [
      {"DBABMA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA",
       %Gpp{
         section_ids: [2],
         sections: [%Gpp.Sections.Tcfv2{vendor_consents: [], version: 2}]
       }},
      {"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN",
       %Gpp{
         section_ids: [2, 6],
         sections: [
           %Gpp.Sections.Tcfv2{vendor_consents: [], version: 2},
           %Gpp.Sections.Uspv1{id: 6, value: "1YNN"}
         ]
       }},
      {"DBABjw~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN",
       %Gpp{
         section_ids: [5, 6],
         sections: [
           %Gpp.DeprecatedSection{id: 5, message: "has been deprecated"},
           %Gpp.Sections.Uspv1{id: 6, value: "1YNN"}
         ]
       }},
      {"DBABBgA~xlgWEYCZAA",
       %Gpp{
         section_ids: [8],
         sections: [
           %Gpp.Sections.Uspca{
             value: "xlgWEYCZAA",
             ore: %Gpp.Sections.Uspca.Core{
               version: 49,
               sale_opt_out_notice: 2,
               sharing_opt_out_notice: 1,
               sensitive_data_limit_use_notice: 1,
               sale_opt_out: 2,
               sharing_opt_out: 0,
               sensitive_data_processing: [0, 1, 1, 2, 0, 1, 0, 1, 2],
               known_child_sensitive_data_consents: [0, 0],
               personal_data_consents: 0,
               mspa_covered_transaction: 2,
               mspa_opt_out_option_mode: 1,
               mspa_service_provider_mode: 2
             },
             section_id: 8,
             usgpc: nil
           }
         ]
       }}
    ]

    for {input, expected} <- examples do
      assert {:ok, expected} == Gpp.parse(input)
    end
  end

  test "invalid header" do
    assert {:error, %Gpp.InvalidHeader{message: msg}} =
             Gpp.parse("gA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA")

    assert "header must be atleast 3 bytes long, got: \"gA\"" == msg
  end
end