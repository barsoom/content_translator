defmodule ContentTranslator.TranslationService do
  def update_in_background(attributes) do
    spawn(ContentTranslator.TranslationService, :update, [ self, attributes ])
  end

  def update(caller, attributes, api \\ Config.translation_api) do
    identifier = attributes[:identifier]
    locale = attributes[:locale]
    value = attributes[:value]
    name = attributes[:name]
    key = "#{identifier}_#{name}"

    api.create(key, value, locale)
    |> TranslationMapping.store(identifier, name)

    send caller, :translation_updated
  end
end
