defmodule ContentTranslator.TextsApiController do
  use ContentTranslator.Web, :controller

  alias ContentTranslator.TranslationService

  plug :action

  def create(conn, params) do
    params
    |> extract_data
    |> send_to_translation_service

    conn |> text("ok")
  end

  defp extract_data(params) do
    params
    |> filter_out_unknown_keys
    |> convert_keys_to_atom
  end

  defp send_to_translation_service(attributes) do
    TranslationService.update_in_background(attributes)
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
