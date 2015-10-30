defmodule ContentTranslator.PageController do
  use ContentTranslator.Web, :controller

  def index(conn, _params) do
    html conn, "This is an API-only app, see the docs at <a href='https://github.com/barsoom/content_translator'>https://github.com/barsoom/content_translator</a>."
  end
end

