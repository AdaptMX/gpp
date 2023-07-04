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
        {:ok, bits} = BitUtil.url_base64_to_bits(input)

        {results, _} =
          Enum.reduce_while(unquote(updated_definition), {[], bits}, fn {field_name,
                                                                         {function, args}},
                                                                        {results, acc} ->
            {value, rest} = apply(function, [acc | args])
            {:cont, {[{field_name, value} | results], rest}}
          end)

        {:ok, struct(__MODULE__, results)}
      end
    end
  end

  @decoders [
    {:bool, &BitUtil.decode_bool/1},
    {:int_2_bit, &BitUtil.decode_bit2/1},
    {:int_2_bit_list, &BitUtil.decode_bit2_list/2},
    {:int_6_bit, &BitUtil.decode_bit6/1},
    {:int_12_bit, &BitUtil.decode_bit12/1}
  ]

  for {type, fun} <- @decoders do
    def resolve_fun(unquote(type)), do: unquote(fun)
  end

  def resolve_fun(other), do: raise(ArgumentError, "unknown type #{inspect(other)}")

  def common_us_core_fields(sensitive_data_fields, child_data_fields) do
    [
      version: :int_6_bit,
      sharing_notice: :int_2_bit,
      sale_opt_out_notice: :int_2_bit,
      targeted_advertising_opt_out_notice: :int_2_bit,
      sale_opt_out: :int_2_bit,
      targeted_advertising_opt_out: :int_2_bit,
      sensitive_data_processing: [int_2_bit_list: [sensitive_data_fields]],
      known_child_sensitive_data_consents: [int_2_bit_list: [child_data_fields]],
      mspa_covered_transaction: :int_2_bit,
      mspa_opt_out_option_mode: :int_2_bit,
      mspa_service_provider_mode: :int_2_bit
    ]
  end
end
