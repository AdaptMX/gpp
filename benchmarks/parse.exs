# rev: dcd855521d135599f49f97a40da67a50038d1c9a
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
# Estimated total run time: 21 s
#
# Benchmarking header ...
# Benchmarking tcf & uspv1 ...
# Benchmarking uspca ...
#
# Name                  ips        average  deviation         median         99th %
# header           507.72 K        1.97 μs  ±2402.72%        1.54 μs        2.63 μs
# uspca            206.22 K        4.85 μs   ±564.03%        4.28 μs        7.84 μs
# tcf & uspv1       19.08 K       52.40 μs    ±17.30%       54.14 μs       78.33 μs
#
# Comparison:
# header           507.72 K
# uspca            206.22 K - 2.46x slower +2.88 μs
# tcf & uspv1       19.08 K - 26.61x slower +50.43 μs

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
