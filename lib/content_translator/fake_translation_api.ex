defmodule ContentTranslator.FakeTranslationApi do
  def reset do
    Agent.update(pid, fn (list) -> [] end)
  end

  def texts do
    Agent.get(pid, fn list -> list end)
  end

  def create(key, value, locale) do
    Agent.update(pid, fn (list) ->
      [
        %{
          key: key,
          value: value,
          locale: locale,
          id: Enum.count(list) + 1
        } | list
      ]
    end)
  end

  defp pid do
    pid = Process.whereis(:fake_translator)

    unless pid do
      {:ok, pid} = Agent.start_link(fn -> [] end)
      Process.register(pid, :fake_translator)
    end

    pid
  end
end
