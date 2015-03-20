defmodule TranslationMapping do
  use Exredis.Api

  def identifier_and_name(string_id) do
    redis
    |> get(key(string_id))
    |> JSON.parse
  end

  def store(string_id, identifier, name) do
    :ok = set(redis, key(string_id), JSON.encode([ identifier, name ]))
  end

  defp key(string_id) do
    "string_#{string_id}"
  end

  defp redis do
    Process.whereis(:redis)
  end
end
