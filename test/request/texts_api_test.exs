defmodule TextsApiTest do
  use ExUnit.Case
  import Plug.Test

  alias ContentTranslator.FakeTranslationApi

  setup do
    FakeTranslationApi.reset
    :ok
  end

  test "creating a text" do
    response = post "/api/texts", identifier: "help_item_25", name: "question", value: "What is elixir?", locale: "en"
    assert response.status == 200

    when_the_translation_has_been_updated(fn ->
      assert FakeTranslationApi.texts == [
        %{ key: "help_item_25_question", value: "What is elixir?", locale: "en", id: 1 }
      ]
    end)
  end

  #test "updating a text"

  #test "fetching changed texts"

  #test "deleting a text" (and twice)

  # the API call is async, so we need to wait for it to report back before
  # checking the result
  defp when_the_translation_has_been_updated(callback) do
    receive do
      :translation_updated ->
        callback.()
      after 1000 ->
        raise "timeout"
    end
  end

  defp post(url, params) do
    conn(:post, url, params)
    |> ContentTranslator.Router.call(ContentTranslator.Router.init([]))
  end

  defp p(thing) do
    IO.inspect(thing)
  end
end
