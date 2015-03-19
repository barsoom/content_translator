defmodule ContentTranslator.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  get "/", ContentTranslator.PageController, :index

  scope "/api", ContentTranslator do
    pipe_through :api
    post "/texts", TextsApiController, :create
  end
end
