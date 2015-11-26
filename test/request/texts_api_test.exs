defmodule TextsApiTest do
  use ExUnit.Case
  import Plug.Test

  alias ContentTranslator.FakeTranslationApi

  setup do
    FakeTranslationApi.reset
    :ok
  end

  test "creating a text" do
    response = post "/api/texts", key: "help_item_25: question", value: "What is elixir?", locale: "en", token: "secret-token"
    assert response.status == 200

    wait_for_the_translation_to_be_processed

    assert FakeTranslationApi.texts == [
      %{ key: "help_item_25: question", value: "What is elixir?", locale: "en", id: 1 }
    ]
  end

  test "updating a text does not create duplicates" do
    post! "/api/texts", key: "help_item_25: question", value: "What is elixir?", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed

    post! "/api/texts", key: "help_item_25: question", value: "What is elixir?!", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed

    assert FakeTranslationApi.texts == [
      %{ key: "help_item_25: question", value: "What is elixir?!", locale: "en", id: 1 }
    ]
  end

  test "creating a text with an invalid token fails" do
    response = post "/api/texts", key: "help_item_25: question", value: "What is elixir?", locale: "en", token: "invalid-secret-token"
    assert response.status == 403
  end

  test "deleting a text" do
    post! "/api/texts", key: "help_item_25: question", value: "What is elixir?", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed
    post! "/api/texts", key: "help_item_25: answer", value: "A...", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed

    response = delete "/api/texts", key: "help_item_25: question", token: "secret-token"
    assert response.status == 200

    # A second delete is a no-op
    response = delete "/api/texts", key: "help_item_25: question", token: "secret-token"
    assert response.status == 200

    wait_for_the_translation_to_be_processed

    assert FakeTranslationApi.texts == [
      %{ key: "help_item_25: answer", value: "A...", locale: "en", id: 2 }
    ]
  end

  # the API call is async, so we need to wait for it to finish
  defp wait_for_the_translation_to_be_processed do
    :timer.sleep 100
  end

  defp post(url, params), do: call(:post, url, params)
  defp delete(url, params), do: call(:delete, url, params)

  defp call(method, url, params) do
    conn(method, url, params)
    |> ContentTranslator.Router.call(ContentTranslator.Router.init([]))
  end

  defp post!(url, params) do
    response = post(url, params)
    assert response.status == 200
    response
  end
end
