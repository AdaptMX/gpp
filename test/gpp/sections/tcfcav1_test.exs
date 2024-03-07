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
              vendor_consents: consents
            }} == Tcfcav1.parse(input)
  end
end
