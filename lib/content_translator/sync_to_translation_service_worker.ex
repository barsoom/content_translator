defmodule ContentTranslator.SyncToTranslationServiceWorker do
  use Toniq.Worker

  def perform(action: action, attributes: attributes) do
    identifier = attributes[:identifier]
    locale = attributes[:locale]
    value = attributes[:value]
    name = attributes[:name]
    key = TranslationKey.build(identifier, name)
    api = Config.translation_api

    case action do
    :create ->
      api.create(key, value, locale)
    :destroy ->
      api.destroy(key)
    nil ->
      raise "Unknown action: #{action}"
    end
  end
end
