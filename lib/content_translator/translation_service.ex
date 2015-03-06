defmodule ContentTranslator.TranslationService do
  def update_in_background(attributes) do
    spawn(ContentTranslator.TranslationService, :update, [ self, attributes ])
  end

  def update(caller, attributes, api \\ Config.translation_api) do
    IO.inspect attributes

    identifier = attributes[:identifier]
    name = attributes[:name]
    value = attributes[:value]
    locale = attributes[:locale]

    api.create("#{identifier}_#{name}", value, locale)

    send caller, :translation_updated
  end
end
