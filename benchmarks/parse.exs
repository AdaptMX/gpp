# rev: 1b1a4a36830610f9e2be98ab864104fdc17ce1d6
# Operating System: Linux
# CPU Information: 12th Gen Intel(R) Core(TM) i9-12900HK
# Number of Available Cores: 20
# Available memory: 62.46 GB
# Elixir 1.15.4
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
# header          1009.60 K        0.99 μs  ±2058.98%        0.78 μs        1.43 μs
# uspca            367.11 K        2.72 μs   ±633.11%        2.34 μs        4.46 μs
# tcf & uspv1       39.65 K       25.22 μs    ±21.82%       23.39 μs       39.08 μs
#
# Comparison:
# header          1009.60 K
# uspca            367.11 K - 2.75x slower +1.73 μs
# tcf & uspv1       39.65 K - 25.46x slower +24.23 μs

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
