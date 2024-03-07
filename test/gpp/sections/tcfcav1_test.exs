defmodule Gpp.Sections.Tcfcav1Test do
  use ExUnit.Case, async: true

  alias Gpp.Sections.{Tcfcav1, Tcf}

  test "example" do
    input =
      "BP7GiMAP7GiMAPoABABGBFCAAAAAAAAAAAXDAMAGUANMAc4A7gCAQElASYAn4BmgDOgGfANeAuEAAAAA.YAAAAAAAAAA"

    consents =
      Enum.reverse([
        202,
        211,
        231,
        238,
        256,
        293,
        294,
        319,
        410,
        413,
        415,
        431,
        737
      ])

    assert {:ok,
            %Tcf{
              version: 1,
              value: input,
              cmp_id: 1000,
              vendor_consents: consents
            }} == Tcfcav1.parse(input)
  end

  test "allows version 2" do
    input =
      "CPzHq4APzHq4ABEACBENAuCMAP-AAP-AAAmDAkAAUADQAJYAXQAzACCAEUAMoAaYA54CSgJMAT8AzQBnQDPgGvASoAn8BbwC4QF7gL_AYOAzABo4DagG4gONAeIA-QCAgEbgI_gSlAlUBMEEwYEgACgAaABLAC6AGYAQQAigBlADTAHPASUBJgCfgGaAM6AZ8A14CVAE_gLeAXCAvcBf4DBwGYANHAbUA3EBxoDxAHyAQEAjcBH8CUoEqgJggA.YAAAAAAAAAA~1---"

    consents = [
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
    ]

    assert {:ok,
            %Tcf{
              version: 2,
              value: input,
              cmp_id: 68,
              vendor_consents: consents
            }} == Tcfcav1.parse(input)
  end
end
