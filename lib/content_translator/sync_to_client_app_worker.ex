defmodule ContentTranslator.SyncToClientAppWorker do
  use Toniq.Worker

  def perform(attributes) do
    Config.client_app_api.update(attributes)
  end
end
