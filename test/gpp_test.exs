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
       }},
      {"DBABjw~CPzHq4APzHq4ABEACBENAuCMAP-AAP-AAAmDAkAAUADQAJYAXQAzACCAEUAMoAaYA54CSgJMAT8AzQBnQDPgGvASoAn8BbwC4QF7gL_AYOAzABo4DagG4gONAeIA-QCAgEbgI_gSlAlUBMEEwYEgACgAaABLAC6AGYAQQAigBlADTAHPASUBJgCfgGaAM6AZ8A14CVAE_gLeAXCAvcBf4DBwGYANHAbUA3EBxoDxAHyAQEAjcBH8CUoEqgJggA.YAAAAAAAAAA~1---",
       %Gpp{
         section_ids: [5, 6],
         sections: [
           %Gpp.Sections.Tcf{
             section_id: 5,
             version: 2,
             vendor_consents: [
               1217,
               1194,
               1189,
               1151,
               1134,
               1028,
               996,
               964,
               909,
               881,
               874,
               839,
               816,
               775,
               767,
               759,
               737,
               734,
               639,
               596,
               431,
               415,
               413,
               410,
               319,
               294,
               293,
               231,
               211,
               202,
               138,
               130,
               102,
               93,
               75,
               52,
               10
             ],
             value:
               "CPzHq4APzHq4ABEACBENAuCMAP-AAP-AAAmDAkAAUADQAJYAXQAzACCAEUAMoAaYA54CSgJMAT8AzQBnQDPgGvASoAn8BbwC4QF7gL_AYOAzABo4DagG4gONAeIA-QCAgEbgI_gSlAlUBMEEwYEgACgAaABLAC6AGYAQQAigBlADTAHPASUBJgCfgGaAM6AZ8A14CVAE_gLeAXCAvcBf4DBwGYANHAbUA3EBxoDxAHyAQEAjcBH8CUoEqgJggA.YAAAAAAAAAA"
           },
           %Gpp.Sections.Uspv1{
             value: "1---",
             opt_out_notice: nil,
             sale_opt_out: nil,
             lspa_covered_transaction: nil,
             section_id: 6,
             version: 1
           }
         ]
       }}
    ]

    for {input, expected} <- examples do
      assert {:ok, expected} == Gpp.parse(input)
    end
  end

  test "invalid headers" do
    headers = ["DBABDA~", "DBABDA~0", "gA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA"]

    for header <- headers do
      assert {:error, _} = Gpp.parse(header)
    end
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

    assert {:error, %Gpp.InvalidSectionRange{message: "got [0, 0, 1]"}} = Gpp.parse(input)
  end

  test "invalid uspv1, skips parsing and returns struct with the value we got" do
    input = "DBABzw~~BVQqAAAAAgA"
    assert {:ok, %{sections: [%Gpp.Sections.Uspv1{value: ""} | _]}} = Gpp.parse(input)
  end

  test "lowercase empty header" do
    input = "dbaa"
    assert {:error, %Gpp.InvalidType{}} = Gpp.parse(input)
  end
end
