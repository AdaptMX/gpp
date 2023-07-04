# rev: 876a6375b00afefc8de61c635cd14b578cec9902
# Operating System: Linux
# CPU Information: 12th Gen Intel(R) Core(TM) i9-12900HK
# Number of Available Cores: 20
# Available memory: 62.46 GB
# Elixir 1.15.1
# Erlang 26.0.2
#
# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 0 ns
# reduction time: 0 ns
# parallel: 1
# inputs: none specified
# Estimated total run time: 7 s
#
# Benchmarking parse ...
#
# Name            ips        average  deviation         median         99th %
# parse      456.77 K        2.19 μs  ±1863.51%        1.77 μs        2.92 μs

gpp = "DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN"

Benchee.run(
  %{
    "parse" => fn -> Gpp.parse(gpp) end,
    "uspco" => fn -> Gpp.Sections.Uspco.parse("bSFgmJQA.YAAA") end
  },
  parallel: System.schedulers_online()
)
