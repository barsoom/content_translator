defmodule ContentTranslator.SyncToTranslationServiceWorker do
  # concurrency only limited to be nice to WTI
  use Toniq.Worker, max_concurrency: 3

  def perform(%{action: :create, key: key, value: value, locale: locale}) do
    api().create(key, value, locale)
  end

  def perform(%{action: :destroy, key: key}) do
    api().destroy(key)
  end

  defp api do
    Config.translation_api()
  end
end
