defmodule Gpp.Sections.Tcfv2Test do
  use ExUnit.Case, async: true
  alias Gpp.Sections.Tcfv2

  test "all segments, with `field` type vendor_consents" do
    input =
      "CGL23UdMFJzvuA9ACCENAXCEAC0AAGrAAA5YA5ht7-_d_7_vd-f-nrf4_4A4hM4JCKoK4YhmAqABgAEgAA.IFut_a83_Ma_t-_SvB3v4-IAeIAACAIgSAAQAIAgEQACEABAAAgAQFAEAIAAAGBAAgAAAAQAIFAAMCQAAgAAQiRAEQAAAAANAAIAAggAIYQFAAARmggBC3ZCYzU2yIA.QFulWfTw4obx_Z2zUj6XkNIAeIAACAIgSAAQAIAgEQACEABAAAgAQFAEAIAAAGBAAgAAAAQAIFAAMCQAAgAAQiRAEQAAAAANAAIAAggAIYQFAAARmggBC3ZCYzU2yIA"

    assert {:ok, %Tcfv2{version: 2, vendor_consents: consents} = res} =
             Tcfv2.parse(input)

    assert length(consents) == 91
    assert 111 in res.vendor_consents
  end

  test "all segments with `range` type vendor_consents" do
    input =
      "CO4D9fZO4D9fZAGABCENAyCsAP_AAE_AABaYGGQHwAAwAKAAsABoAGQAOAAgABUADIAGgAOoAegB8AEUAJgAUAAwgBoAEJAI4AkABLACiAFaAMsAeAA_QCAAEHAIwAWYBJ4C8wGGAIPAHADQAIQARwAywB4AEAAIOASMgDAAqACYAI4AZYBGAF5iIAYAKgBlgEYCQDQAFgAZAA4ACAAFQANAAfABMAEsAMsAfoBGAF5hoAYAKgBlgEYFQBgAVABMAEcAMsAjAC8x0AwABYAGQAOAAgABUADQAHwATABLAD9AIwAvMhAGAAWABkAFQATABHAEYJQBgAFgAZAA4AEwAjAC8ykAoABYAGQAOAAgABUADQAJgA_QCMALzAAA.YAAAAAAAAAAA"

    assert {:ok, %Tcfv2{version: 2, vendor_consents: consents} = res} =
             Tcfv2.parse(input)

    assert length(consents) == 35
    assert 143 in res.vendor_consents
  end

  test "returns parseError for invalid input" do
    assert {:error, %Tcfv2.DecodeError{}} =
             Tcfv2.parse("WAT")
  end

  test "refuses to parse version 1" do
    input =
      "BOtn-dKO4E4lPAKAkBITDW-AAAAyN7_______9_-____9uz_Ov_v_f__33e8__9v_l_7_-___u_-23d4u_1vf99yfmx-7etr3tp_47ues2_Xurf_71__3z3_9pxP78E89r7335EQ_v-_t-b7BCHN_Y2v-8K96lPKACE"

    assert {:error, %Gpp.Sections.Tcfv2.DecodeError{message: "got TCF v1"}} ==
             Tcfv2.parse(input)
  end
end
