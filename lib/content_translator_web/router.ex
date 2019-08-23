defmodule ContentTranslatorWeb.Router do
  use ContentTranslatorWeb, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ~w(html)
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  # Used by deploy scripts
  get "/revision", ContentTranslatorWeb.PageController, :revision

  get "/", ContentTranslatorWeb.PageController, :index
  get "/boom", ContentTranslatorWeb.BoomController, :index

  get "/search", ContentTranslatorWeb.PageController, :redirect_to_translation_service

  scope "/api", ContentTranslatorWeb do
    pipe_through :api
    post "/texts", TextsApiController, :create
    delete "/texts", TextsApiController, :destroy
    post "/wti_webhook", WtiWebhookApiController, :create
  end
end
