defmodule Gpp.Decoder do
  alias Gpp.BitUtil

  defmacro __using__(definition) do
    definition = Keyword.get(definition, :common_us_core, definition)

    definition =
      case definition do
        {sensitive_data_fields, child_data_fields} ->
          common_us_core_fields(sensitive_data_fields, child_data_fields)

        custom ->
          custom
      end

    updated_definition =
      Enum.map(definition, fn
        {name, [{fun, args}]} -> {name, {resolve_fun(fun), args}}
        {name, fun} -> {name, {resolve_fun(fun), []}}
      end)

    quote do
      defstruct unquote(Enum.map(definition, &elem(&1, 0)))

      def parse(input) do
        with {:ok, bits} <- BitUtil.url_base64_to_bits(input),
             {:ok, results, _rest} <- parse_bits(bits) do
          {:ok, struct(__MODULE__, results)}
        end
      end

      defp parse_bits(bits) do
        Enum.reduce_while(unquote(updated_definition), {:ok, [], bits}, fn {field_name,
                                                                            {function, args}},
                                                                           {:ok, results, acc} ->
          case apply(function, [acc | args]) do
            {:ok, value, rest} ->
              {:cont, {:ok, [{field_name, value} | results], rest}}

            {:error, _} = e ->
              {:halt, e}
          end
        end)
      end
    end
  end

  @decoders [
    {:bool, &BitUtil.decode_bool/1},
    {:int_2bit, &BitUtil.parse_2bit_int/1},
    {:int_2bit_list, &BitUtil.parse_2bit_int_list/2},
    {:int_3bit, &BitUtil.parse_3bit_int/1},
    {:int_6bit, &BitUtil.parse_6bit_int/1},
    {:int_12bit, &BitUtil.parse_12bit_int/1}
  ]

  for {type, fun} <- @decoders do
    def resolve_fun(unquote(type)), do: unquote(fun)
  end

  def resolve_fun(other), do: raise(ArgumentError, "unknown type #{inspect(other)}")

  def common_us_core_fields(sensitive_data_fields, child_data_fields) do
    [
      version: :int_6bit,
      sharing_notice: :int_2bit,
      sale_opt_out_notice: :int_2bit,
      targeted_advertising_opt_out_notice: :int_2bit,
      sale_opt_out: :int_2bit,
      targeted_advertising_opt_out: :int_2bit,
      sensitive_data_processing: [int_2bit_list: [sensitive_data_fields]],
      known_child_sensitive_data_consents: [int_2bit_list: [child_data_fields]],
      mspa_covered_transaction: :int_2bit,
      mspa_opt_out_option_mode: :int_2bit,
      mspa_service_provider_mode: :int_2bit
    ]
  end
end
