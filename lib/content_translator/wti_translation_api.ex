# This module is only tested manually for now.
# TODO: Look into webmocks and vcr-like tools.

defmodule ContentTranslator.WtiTranslationApi do
  alias ContentTranslator.WtiTranslationApi.Endpoint

  def create(key, value, locale) do
    create_string(key)
    |> update_translation(value, locale)
  end

  defp create_string(key) do
    find_existing_strings(key)
    |> use_existing_string_or_create_a_new_one(key)
  end

  defp update_translation(string_id, value, locale) do
    # WTI does not like string begining or ending with whitespace: "Error saving translation", "406 Not Acceptable".
    # So far just stripping it away hasn't been a problem, but if it's a problem for you, ask WTI.
    text = String.strip(value)

    post("/strings/#{string_id}/locales/#{locale}/translations", %{ text: text })
    |> verify_response_code(202) # Accepted
  end

  defp use_existing_string_or_create_a_new_one([], key) do
    post("/strings", %{ key: key })
    |> verify_response_code(201)
    |> parse_body
    |> get_id
  end

  defp use_existing_string_or_create_a_new_one(strings, _key) do
    strings
    |> hd
    |> get_id
  end

  defp get_id(data) do
    data |> Map.get("id")
  end

  defp find_existing_strings(key) do
    get("/strings?filters[key]=#{key}")
    |> verify_response_code(200)
    |> parse_body
  end

  defp parse_body(response) do
    JSON.parse(response.body)
  end

  defp verify_response_code(response, code) do
    if response.status_code != code do
      raise "Unexpected response: #{inspect(response)}"
    end

    response
  end

  defp post(path, data), do: Endpoint.post(path, data)
  defp get(path), do: Endpoint.get(path)
end
