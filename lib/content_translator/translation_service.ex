defmodule ContentTranslator.TranslationService do
  use GenServer

  def start_link do
    state = []
    GenServer.start_link(__MODULE__, state, [ name: :translation_service ])
  end

  def handle_cast({ caller, attributes }, state) do
    update(caller, attributes)
    {:noreply, state}
  end

  def run_in_background(action, attributes) do
    # This uses "cast" to make it async, but it will only process one
    # at a time.

    # Making parallel calls for the same string (one for each locale)
    # won't work because of how the WTI API works. It assumes you know if
    # a string is created or not.

    # Handling different strings at once should work, but if you do that,
    # limit the number of parallel calls to be nice to WTI.
    GenServer.cast(:translation_service, { self, [ action, attributes ] })
  end

  def update(caller, [ action, attributes ], api \\ Config.translation_api) do
    identifier = attributes[:identifier]
    locale = attributes[:locale]
    value = attributes[:value]
    name = attributes[:name]
    key = TranslationKey.build(identifier, name)

    case action do
    :create ->
      api.create(key, value, locale)
    nil ->
      raise "Unknown action: #{action}"
    end

    send caller, :done
  end
end
