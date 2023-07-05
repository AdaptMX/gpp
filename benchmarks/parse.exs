# Operating System: Linux
# CPU Information: 12th Gen Intel(R) Core(TM) i9-12900HK
# Number of Available Cores: 20
# Available memory: 62.46 GB
# Elixir 1.15.2
# Erlang 26.0.2
#
# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 0 ns
# reduction time: 0 ns
# parallel: 1
# inputs: none specified
# Estimated total run time: 21 s
#
# Benchmarking header ...
# Benchmarking tcf & uspv1 ...
# Benchmarking uspca ...
#
# Name                  ips        average  deviation         median         99th %
# header          1003.31 K        1.00 μs  ±2294.40%        0.78 μs        1.46 μs
# uspca            380.75 K        2.63 μs   ±576.13%        2.21 μs        4.25 μs
# tcf & uspv1       36.89 K       27.11 μs    ±19.34%       25.26 μs       37.67 μs
#
# Comparison: 
# header          1003.31 K
# uspca            380.75 K - 2.64x slower +1.63 μs
# tcf & uspv1       36.89 K - 27.20x slower +26.11 μs

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
