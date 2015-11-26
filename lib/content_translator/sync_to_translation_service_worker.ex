defmodule ContentTranslator.SyncToTranslationServiceWorker do
  # concurrency only limited to be nice to WTI
  use Toniq.Worker, max_concurrency: 3

  def perform(%{action: :create, key: key, value: value, locale: locale}) do
    api.create(key, value, locale)
  end

  def perform(%{action: :destroy, key: key}) do
    api.destroy(key)
  end

  def perform(%{action: :destroy, identifier: identifier, name: name}) do
    key(identifier, name)
    |> api.destroy
  end

  def perform(%{action: :create, identifier: identifier, name: name, value: value, locale: locale}) do
    key(identifier, name)
    |> api.create(value, locale)
  end

  defp key(identifier, name) do
    TranslationKey.build(identifier, name)
  end

  defp api do
    Config.translation_api
  end
end
