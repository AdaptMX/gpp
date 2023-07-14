defmodule Gpp.Sections.Uspv1 do
  @behaviour Gpp.Section
  @type t :: %__MODULE__{
          value: String.t(),
          section_id: pos_integer(),
          opt_out_notice: boolean(),
          sale_opt_out: boolean(),
          lspa_covered_transaction: boolean(),
          version: pos_integer()
        }
  defstruct [
    :value,
    :opt_out_notice,
    :sale_opt_out,
    :lspa_covered_transaction,
    section_id: 6,
    version: 1
  ]

  defmodule InvalidVersion do
    defexception [:message]
  end

  defmodule UnexpectedValue do
    defexception [:message]
  end

  @impl Gpp.Section
  def parse(input) when byte_size(input) == 4 do
    with {:ok, version, rest} <- version(input),
         {:ok, opt_out_notice, rest} <- parse_field(rest),
         {:ok, sale_opt_out, rest} <- parse_field(rest),
         {:ok, lspa_covered_transaction, _} <- parse_field(rest) do
      {:ok,
       %__MODULE__{
         version: version,
         value: input,
         opt_out_notice: opt_out_notice,
         sale_opt_out: sale_opt_out,
         lspa_covered_transaction: lspa_covered_transaction
       }}
    end
  end

  def parse(value), do: {:ok, %__MODULE__{value: value}}

  defp version(<<"1", rest::binary>>), do: {:ok, 1, rest}
  defp version(other), do: {:error, %InvalidVersion{message: "got #{inspect(other)}"}}

  defp parse_field(<<value::binary-size(1), rest::binary>>) do
    with {:ok, value} <- cast_field(value) do
      {:ok, value, rest}
    end
  end

  defp cast_field("Y"), do: {:ok, true}
  defp cast_field("N"), do: {:ok, false}
  defp cast_field("-"), do: {:ok, nil}
  defp cast_field(other), do: {:error, %UnexpectedValue{message: "got #{inspect(other)}"}}
end
