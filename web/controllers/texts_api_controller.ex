defmodule ContentTranslator.TextsApiController do
  use ContentTranslator.Web, :api_controller

  alias ContentTranslator.SyncToTranslationServiceWorker

  plug :action

  def create(conn, params), do: handle_request(conn, params, :create)
  def destroy(conn, params), do: handle_request(conn, params, :destroy)

  defp handle_request(conn, params, action) do
    params
    |> extract_data(action)
    |> Toniq.enqueue_to(SyncToTranslationServiceWorker)

    conn |> text("ok")
  end

  defp extract_data(params, action) do
    params
    |> filter_out_unknown_keys
    |> convert_keys_to_atom
    |> add_action(action)
  end

  defp filter_out_unknown_keys(map) do
    map |> Map.take([ "identifier", "name", "value", "locale" ])
  end

  defp convert_keys_to_atom(map) do
    map
    |> Enum.map(fn ({key, value}) ->
      { String.to_atom(key), value }
    end)
    |> Enum.into(%{})
  end

  defp add_action(attributes, action) do
    attributes
    |> Map.put(:action, action)
  end
end
