defmodule WtiWebhookApiTest do
  use ExUnit.Case
  import Plug.Test

  alias ContentTranslator.FakeClientAppApi

  setup do
    FakeClientAppApi.reset
  end

  test "notifies the client app about an updated text" do
    post "/api/wti_webhook", format: "json", payload: payload, token: "secret-token"

    wait_for_the_translation_update_to_sent

    assert FakeClientAppApi.last_update == %{ identifier: "help_item_20", name: "question", text: "English text", locale: "en" }
  end

  test "ignores changes not made by users to avoid infinite loops" do
    post "/api/wti_webhook", format: "json", payload: non_user_payload, token: "secret-token"

    wait_for_the_translation_update_to_sent

    assert FakeClientAppApi.last_update == nil
  end

  test "updating a text with an invalid token fails" do
    response = post "/api/wti_webhook", format: "json", payload: payload, token: "invalid-secret-token"
    assert response.status == 403
  end

  defp payload do
    '{"project_id":1,"string_id":456,"user_id":10,"locale":"en","file_id":null,"api_url":"URL","translation":{"id":123,"locale":"en","text":"English text","status":"status_unproofread","created_at":"2015-03-19T12:55:52Z","updated_at":"2015-03-19T12:59:56Z","version":6,"string":{"id":456,"key":"help_item_20: question","plural":false,"type":"String","dev_comment":"","status":"Current"}}}'
  end

  defp non_user_payload do
    '{"project_id":1,"string_id":456,"user_id":null,"locale":"en","file_id":null,"api_url":"URL","translation":{"id":123,"locale":"en","text":"English text","status":"status_unproofread","created_at":"2015-03-19T12:55:52Z","updated_at":"2015-03-19T12:59:56Z","version":6,"string":{"id":456,"key":"help_item_20: question","plural":false,"type":"String","dev_comment":"","status":"Current"}}}'
  end

  defp post(url, params) do
    conn(:post, url, params)
    |> ContentTranslator.Router.call(ContentTranslator.Router.init([]))
  end

  # the API call is async, so we need to wait for it to finish
  defp wait_for_the_translation_update_to_sent do
    :timer.sleep 100
  end
end
