defmodule TextsTest do
  use ExUnit.Case
  import Plug.Test

  test "redirecting to WTI" do
    response = get("/search", query: "help_item_25:", from: "sv", to: "de")
    assert response.status == 302

    assert response.resp_body =~
             "https://webtranslateit.com/projects/1234/locales/sv..de/strings?s=help_item_25:"
  end

  defp get(url, params), do: call(:get, url, params)

  defp call(method, url, params) do
    conn(method, url, params)
    |> ContentTranslatorWeb.Router.call(ContentTranslatorWeb.Router.init([]))
  end
end
