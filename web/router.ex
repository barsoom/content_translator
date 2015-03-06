defmodule ContentTranslator.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/api", ContentTranslator do
    pipe_through :api
    post "/texts", TextsApiController, :create
  end
end
