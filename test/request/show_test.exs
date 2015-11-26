defmodule TextsTest do
  use ExUnit.Case
  import Plug.Test

  test "redirecting to WTI" do
    response = get "/show", key: "help_item_25: question", from: "sv", to: "de"
    assert response.status == 302
    assert response.resp_body =~ "https://webtranslateit.com/projects/1234/locales/sv..de/strings/4567"
  end

  defp get(url, params), do: call(:get, url, params)

  defp call(method, url, params) do
    conn(method, url, params)
    |> ContentTranslator.Router.call(ContentTranslator.Router.init([]))
  end
end
