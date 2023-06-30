defmodule GppTest do
  use ExUnit.Case
  doctest Gpp

  test "decode headers" do
    examples = [{"DBABM", 1}, {"DBACNY", 2}, {"DBABjw", 1}]

    for {input, section_range} <- examples do
      assert %Gpp{type: 3, version: 1, section_range: ^section_range, sections: []} =
               Gpp.decode(input)
    end
  end

  test "full gpp strings" do
    examples = [
      {"DBABMA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA", []},
      {"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN", []},
      {"DBABjw~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN", []}
    ]

    for {input, _} <- examples do
      Gpp.decode(input)
      |> IO.inspect()
    end
  end
end
