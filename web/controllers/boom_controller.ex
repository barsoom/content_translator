defmodule ContentTranslator.BoomController do
  use ContentTranslator.Web, :controller

  def index(_conn, _params) do
    raise "Boom! (checking error reporting)"
  end
end

