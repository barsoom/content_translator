defmodule ContentTranslator.SyncToClientAppWorker do
  # concurrency only limited to be nice to the client app
  use Toniq.Worker, max_concurrency: 3

  def perform(attributes) do
    Config.client_app_api.update(attributes)
  end
end
