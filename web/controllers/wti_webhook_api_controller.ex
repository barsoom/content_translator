defmodule ContentTranslator.WtiWebhookApiController do
  use ContentTranslator.Web, :api_controller

  alias ContentTranslator.SyncToClientAppWorker

  def create(conn, %{"payload" => payload}) do
    payload
    |> process

    text(conn, "ok")
  end

  defp process(payload) do
    notify_client_app(payload)
  end

  # Changes not made by users are ignored so
  # that we don't cause infinite loops when this
  # app changes data in WTI.
  defp notify_client_app(%{"user_id" => nil}) do
    # no-op
  end

  defp notify_client_app(payload) do
    payload
    |> extract_data
    |> Toniq.enqueue_to(SyncToClientAppWorker)
  end

  defp extract_data(payload) do
    %{
      key: payload["translation"]["string"]["key"],
      value: payload["translation"]["text"],
      locale: payload["locale"]
    }
  end
end
