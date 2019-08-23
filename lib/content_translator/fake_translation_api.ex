defmodule ContentTranslator.FakeTranslationApi do
  def reset do
    Agent.update(pid(), fn _list -> [] end)
  end

  def texts do
    Agent.get(pid(), fn list -> list end)
  end

  def create(key, value, locale) do
    known_entry = Enum.find(texts(), &(&1.key == key))
    create_or_update(key, value, locale, known_entry)
  end

  def destroy(key) do
    Agent.update(pid(), fn list ->
      list
      |> Enum.reject(&(&1.key == key))
    end)
  end

  def url(_key, from, to) do
    "https://webtranslateit.com/projects/1234/locales/#{from}..#{to}/strings/4567"
  end

  defp create_or_update(key, value, locale, _known_entry = nil) do
    Agent.update(pid(), fn list ->
      list
      |> add_entry(key, value, locale, Enum.count(list) + 1)
    end)
  end

  defp create_or_update(key, value, locale, known_entry) do
    Agent.update(pid(), fn list ->
      list
      |> Enum.reject(&(&1 == known_entry))
      |> add_entry(key, value, locale, known_entry.id)
    end)
  end

  defp add_entry(list, key, value, locale, id) do
    [
      %{
        key: key,
        value: value,
        locale: locale,
        id: id
      }
      | list
    ]
  end

  defp pid do
    pid = Process.whereis(:fake_translator)

    if pid do
      pid
    else
      {:ok, pid} = Agent.start_link(fn -> [] end)
      Process.register(pid, :fake_translator)
      pid
    end
  end
end
