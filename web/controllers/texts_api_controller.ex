defmodule ContentTranslator.TextsApiController do
  use ContentTranslator.Web, :api_controller

  alias ContentTranslator.TranslationService

  plug :action

  def create(conn, params), do: handle_request(conn, params, :create)
  def destroy(conn, params), do: handle_request(conn, params, :destroy)

  defp handle_request(conn, params, action) do
    params
    |> extract_data
    |> send_to_translation_service(action)

    conn |> text("ok")
  end

  defp extract_data(params) do
    params
    |> filter_out_unknown_keys
    |> convert_keys_to_atom
  end

  defp send_to_translation_service(attributes, action) do
    TranslationService.run_in_background(action, attributes)
  end

  defp filter_out_unknown_keys(map) do
    map |> Map.take([ "identifier", "name", "value", "locale" ])
  end

  defp convert_keys_to_atom(map) do
    map
    |> Enum.map(fn (tuple) ->
      [ key, value ] = Tuple.to_list(tuple)
      { String.to_atom(key), value }
    end)
    |> Enum.into(%{})
  end
end
