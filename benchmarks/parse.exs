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

tcf_uspv1 =
  "DBACNYA~CO9AzAHO9AzAHAcABBENBACgAAAAAH_AACiQHFNf_X_fb3_j-_59_9t0eY1f9_7_v20zjgeds-8Nyd_X_L8X4mM7vB36pq4KuR4Eu3LBAQdlHOHcTUmw6IkVqTPsbk2Mr7NKJ7PEinMbe2dYGH9_n9XTuZKY79_s___z__-__v__7_f_r-3_3_vp9V---wOJAJMNS-AizEscCSaNKoUQIQriQ6AEAFFCMLRNYQErgp2VwEfoIGACA1ARgRAgxBRiyCAAAAAJKIgJADwQCIAiAQAAgBUgIQAEaAILACQMAgAFANCwAigCECQgyOCo5TAgIkWignkrAEou9jDCEMooAaBAAAAA.YAAAAAAAAAAA~1YNN"

header = "DBACNYA"
uspca = "DBABBgA~xlgWEYCZAA"

Benchee.run(
  %{
    "header" => fn -> Gpp.parse(header) end,
    "tcf & uspv1" => fn -> Gpp.parse(tcf_uspv1) end,
    "uspca" => fn -> Gpp.parse(uspca) end
  }
  # parallel: System.schedulers_online()
)
