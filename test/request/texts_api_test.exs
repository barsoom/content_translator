defmodule TextsApiTest do
  use ExUnit.Case
  import Plug.Test

  alias ContentTranslator.FakeTranslationApi

  setup do
    FakeTranslationApi.reset
    :ok
  end

  test "creating a text" do
    response = post "/api/texts", identifier: "help_item_25", name: "question", value: "What is elixir?", locale: "en", token: "secret-token"
    assert response.status == 200

    wait_for_the_translation_to_be_processed

    assert FakeTranslationApi.texts == [
      %{ key: "help_item_25: question", value: "What is elixir?", locale: "en", id: 1 }
    ]
  end

  test "updating a text does not create duplicates" do
    post! "/api/texts", identifier: "help_item_25", name: "question", value: "What is elixir?", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed

    post! "/api/texts", identifier: "help_item_25", name: "question", value: "What is elixir?!", locale: "en", token: "secret-token"
    wait_for_the_translation_to_be_processed

    assert FakeTranslationApi.texts == [
      %{ key: "help_item_25: question", value: "What is elixir?!", locale: "en", id: 1 }
    ]
  end

  test "creating a text with an invalid token fails" do
    response = post "/api/texts", identifier: "help_item_25", name: "question", value: "What is elixir?", locale: "en", token: "invalid-secret-token"
    assert response.status == 403
  end

  #test "fetching changed texts"

  #test "deleting a text" (and twice)

  # the API call is async, so we need to wait for it to report back before
  # checking the result
  defp wait_for_the_translation_to_be_processed do
    receive do
      :done ->
        # continue test
      after 1000 ->
        raise "timeout"
    end
  end

  defp post(url, params), do: call(:post, url, params)

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
