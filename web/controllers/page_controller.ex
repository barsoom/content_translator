defmodule ContentTranslator.PageController do
  use ContentTranslator.Web, :controller

  def index(conn, _params) do
    html conn, "This is an API-only app, see the docs at <a href='https://github.com/barsoom/content_translator'>https://github.com/barsoom/content_translator</a>."
  end

  def redirect_to_translation_service(conn, params) do
    url = translation_api.url(params["key"], params["source_locale"], params["destination_locale"])
    redirect(conn, external: url)
  end

  defp translation_api, do: Config.translation_api
end

