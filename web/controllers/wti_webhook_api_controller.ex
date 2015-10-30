defmodule ContentTranslator.WtiWebhookApiController do
  use ContentTranslator.Web, :api_controller

  alias ContentTranslator.SyncToClientAppWorker

  def create(conn, %{ "format" => "json", "payload" => payload }) do
    payload
    |> JSON.parse
    |> process

    text conn, "ok"
  end

  defp process(payload) do
    notify_client_app(payload, payload["user_id"])
  end

  # Changes not made by users are ignored so
  # that we don't cause infinite loops when this
  # app changes data in WTI.
  defp notify_client_app(_payload, nil) do
    # no-op
  end

  defp notify_client_app(payload, user_id) do
    payload
    |> extract_data
    |> Toniq.enqueue_to(SyncToClientAppWorker)
  end

  defp extract_data(payload) do
    [ identifier, name ] = TranslationKey.parse(payload["translation"]["string"]["key"])

    %{
      identifier: identifier,
      name: name,
      text: payload["translation"]["text"],
      locale: payload["locale"]
    }
  end
end
