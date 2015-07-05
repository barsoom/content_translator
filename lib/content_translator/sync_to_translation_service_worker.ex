defmodule ContentTranslator.SyncToTranslationServiceWorker do
  use Toniq.Worker

  def perform(action: :destroy, identifier: identifier, name: name) do
    key(identifier, name)
    |> api.destroy
  end

  def perform(action: :create, identifier: identifier, name: name, value: value, locale: locale) do
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
