defmodule Gpp.Sections.Tcf.VendorList do
  @moduledoc false

  alias Gpp.BitUtil
  alias Gpp.Sections.Tcf.DecodeError

  @encoding_type %{
    0 => :field,
    1 => :range
  }

  def decode(input) do
    with {:ok, max_id, rest} <- BitUtil.decode_bit16(input),
         {:ok, encoding_type, rest} <- encoding_type(rest) do
      do_decode(encoding_type, rest, max_id)
    end
  end

  defp do_decode(:field, input, max_id) do
    init = {:ok, [], input}

    Enum.reduce_while(1..max_id, init, fn
      i, {:ok, entries, [1 | rest]} ->
        {:cont, {:ok, [i | entries], rest}}

      _, {:ok, entries, [0 | rest]} ->
        {:cont, {:ok, entries, rest}}

      _, {:ok, entries, []} ->
        {:cont, {:ok, entries, []}}

      _, _ ->
        {:halt, invalid_input_error()}
    end)
  end

  defp do_decode(:range, input, _max_id) do
    with {:ok, num_entries, rest} <- num_entries(input) do
      Enum.reduce_while(1..num_entries, {:ok, [], rest}, fn _, {:ok, entries, remaining} ->
        with {:ok, is_id_range?, remaining} <- is_id_range?(remaining),
             {:ok, _, _} = result <- extract_entries(remaining, entries, is_id_range?) do
          {:cont, result}
        else
          error -> {:halt, error}
        end
      end)
    end
  end

  defp extract_entries(input, entries, true) do
    with {:ok, start_id, rest} <- BitUtil.decode_bit16(input),
         {:ok, end_id, rest} <- BitUtil.decode_bit16(rest) do
      updated_entries = Enum.reduce(start_id..end_id, entries, fn id, acc -> [id | acc] end)
      {:ok, updated_entries, rest}
    else
      _ -> {:error, %DecodeError{message: "invalid vendor list range"}}
    end
  end

  defp extract_entries(input, entries, false) do
    with {:ok, vendor_id, rest} <- BitUtil.decode_bit16(input) do
      {:ok, [vendor_id | entries], rest}
    end
  end

  defp encoding_type([type | rest]) do
    case Map.get(@encoding_type, type, :undefined) do
      :undefined -> {:error, %DecodeError{message: "invalid vendor list encoding type"}}
      type -> {:ok, type, rest}
    end
  end

  defp num_entries(input) do
    with {:ok, num, rest} <- BitUtil.parse_12bit_int(input) do
      {:ok, num, rest}
    end
  end

  defp is_id_range?([1 | rest]), do: {:ok, true, rest}
  defp is_id_range?([0 | rest]), do: {:ok, false, rest}
  defp is_id_range?(_), do: invalid_input_error()

  defp invalid_input_error, do: {:error, %DecodeError{message: "invalid input"}}
end
