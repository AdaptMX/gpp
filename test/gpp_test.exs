defmodule GppTest do
  use ExUnit.Case
  doctest Gpp

  test "full gpp strings" do
    examples = [
      {"DBABMA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA",
       %Gpp{
         section_ids: [2],
         sections: [
           %Gpp.Sections.Tcf{
             section_id: 2,
             vendor_consents: [],
             version: 2,
             value: "CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA"
           }
         ]
       }},
      {"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN",
       %Gpp{
         section_ids: [2, 6],
         sections: [
           %Gpp.Sections.Tcf{
             section_id: 2,
             vendor_consents: [],
             version: 2,
             value: "CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA"
           },
           %Gpp.Sections.Uspv1{
             section_id: 6,
             lspa_covered_transaction: false,
             opt_out_notice: true,
             sale_opt_out: false,
             value: "1YNN",
             version: 1
           }
         ]
       }},
      {
        "DBABjw~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN",
        %Gpp{
          section_ids: [5, 6],
          sections: [
            %Gpp.Sections.Tcf{
              section_id: 5,
              vendor_consents: [],
              version: 2,
              value: "CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA"
            },
            %Gpp.Sections.Uspv1{
              section_id: 6,
              lspa_covered_transaction: false,
              opt_out_notice: true,
              sale_opt_out: false,
              value: "1YNN",
              version: 1
            }
          ]
        }
      },
      {"DBABBgA~xlgWEYCZAA",
       %Gpp{
         section_ids: [8],
         sections: [
           %Gpp.Sections.Uspca{
             value: "xlgWEYCZAA",
             core: %Gpp.Sections.Uspca.Core{
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

  test "completely invalid input" do
    for invalid <- [nil, "", 0] do
      assert {:error, %Gpp.InvalidHeader{}} = Gpp.parse(invalid)
    end
  end

  test "section_id_to_name!/1" do
    assert "tcfeu2" == Gpp.section_id_to_name!(2)

    assert_raise(Gpp.UnknownSection, fn ->
      Gpp.section_id_to_name!(999)
    end)
  end

  test "section_name_to_id!/1" do
    assert 2 == Gpp.section_name_to_id!("tcfeu2")

    assert_raise(Gpp.UnknownSection, fn ->
      Gpp.section_name_to_id!("wat")
    end)
  end

  test "header contains invalid fibonacci range" do
    input =
      "DBACOe~CPpE-EAPpE-EAEXbkAENDNCwAP_AAH_AACiQGMwAgF5gMZAvOACAvMAA~CPpE-EAPpE-EAEXbkAENDNCgAf-AAP-AAAYzACAXmAxkC84AIC8w~1-N-"

    assert {:ok, gpp} = Gpp.parse(input)
  end

  test "invalid uspv1, skips parsing and returns struct with the value we got" do
    input = "DBABzw~~BVQqAAAAAgA"
    assert {:ok, %{sections: [%Gpp.Sections.Uspv1{value: ""} | _]}} = Gpp.parse(input)
  end
end
