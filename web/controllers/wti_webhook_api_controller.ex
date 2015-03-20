defmodule ContentTranslator.WtiWebhookApiController do
  use ContentTranslator.Web, :controller

  plug :action

  # Example payload
  # {"project_id":1,"string_id":456,"user_id":10,"locale":"en","file_id":null,"api_url":"URL","translation":{"id":123,"locale":"en","text":"English text","status":"status_unproofread","created_at":"2015-03-19T12:55:52Z","updated_at":"2015-03-19T12:59:56Z","version":6,"string":{"id":456,"key":"test.segment","plural":false,"type":"String","dev_comment":"","status":"Current"}}}
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
    #IO.inspect TranslationMapping.identifier_and_name(payload["string_id"])
    IO.inspect payload
  end
end
