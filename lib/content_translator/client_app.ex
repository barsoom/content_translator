defmodule ContentTranslator.ClientApp do
  use GenServer

  def start_link do
    state = []
    GenServer.start_link(__MODULE__, state, [ name: :client_app ])
  end

  def handle_cast({ caller, attributes }, state) do
    update(caller, attributes)
    {:noreply, state}
  end

  def update_in_background(attributes) do
    GenServer.cast(:client_app, { self, attributes })
  end

  def update(caller, attributes, api \\ Config.client_app_api) do
    api.update(attributes)

    send caller, :done
  end
end
