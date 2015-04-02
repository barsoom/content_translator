defmodule ContentTranslator.FakeClientAppApi do
  def update(attributes) do
    Agent.update(pid, fn (_old_attributes) ->
      attributes
    end)
  end

  def last_update do
    Agent.get(pid, fn attributes -> attributes end)
  end

  defp pid do
    pid = Process.whereis(:fake_client_app)

    unless pid do
      {:ok, pid} = Agent.start_link(fn -> nil end)
      Process.register(pid, :fake_client_app)
    end

    pid
  end
end
