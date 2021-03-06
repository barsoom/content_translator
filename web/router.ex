defmodule ContentTranslator.Router do
  use ContentTranslator.Web, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ~w(html)
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  # Used by deploy scripts
  get "/revision", ContentTranslator.PageController, :revision

  get "/", ContentTranslator.PageController, :index
  get "/boom", ContentTranslator.BoomController, :index

  get "/search", ContentTranslator.PageController, :redirect_to_translation_service

  scope "/api", ContentTranslator do
    pipe_through :api
    post "/texts", TextsApiController, :create
    delete "/texts", TextsApiController, :destroy
    post "/wti_webhook", WtiWebhookApiController, :create
  end
end
