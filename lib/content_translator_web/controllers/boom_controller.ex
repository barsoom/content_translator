defmodule ContentTranslatorWeb.BoomController do
  use ContentTranslatorWeb, :controller

  def index(_conn, _params) do
    raise "Boom! (checking error reporting)"
  end
end
