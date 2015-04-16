defmodule ContentTranslator.BoomController do
  use ContentTranslator.Web, :controller

  plug :action

  def index(conn, _params) do
    raise "Boom! (checking error reporting)"
  end
end

