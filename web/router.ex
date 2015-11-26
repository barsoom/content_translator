defmodule ContentTranslator.Router do
  use ContentTranslator.Web, :router

  pipeline :browser do
    plug :accepts, ~w(html)
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  get "/", ContentTranslator.PageController, :index
  get "/boom", ContentTranslator.BoomController, :index

  scope "/api", ContentTranslator do
    pipe_through :api
    post "/texts", TextsApiController, :create
    delete "/texts", TextsApiController, :destroy
    post "/wti_webhook", WtiWebhookApiController, :create
  end
end
