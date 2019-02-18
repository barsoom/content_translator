# This module is only tested manually for now.
# TODO: Look into webmocks and vcr-like tools.

defmodule ContentTranslator.WtiTranslationApi do
  alias ContentTranslator.WtiTranslationApi.Endpoint

  def create(key, value, locale) do
    create_string(key)
    |> update_translation(value, locale)
  end

  def destroy(key) do
    find_existing_strings(key)
    |> delete_when_a_string_exists
  end

  defp delete_when_a_string_exists([]) do
    # no-op when there is no string to delete
  end

  defp delete_when_a_string_exists(strings) do
    strings
    |> hd
    |> get_id
    |> delete_by_id
  end

  defp delete_by_id(id) do
    delete("/strings/#{id}")
    |> verify_response_code(202)
  end

  defp create_string(key) do
    find_existing_strings(key)
    |> use_existing_string_or_create_a_new_one(key)
  end

  defp update_translation(string_id, value, locale) do
    # WTI does not like strings beginning or ending with whitespace: "Error saving translation", "406 Not Acceptable".
    # So far just stripping it away hasn't been a problem, but if it's a problem for you, ask WTI.
    text = String.trim(value)

    # We pass "validation: false" here since we can't give any feedback to the client system in any
    # simple way if the data does not pass the WTI validations. It's probably enough that you
    # are prompted by those errors in the WTI UI.
    post("/strings/#{string_id}/locales/#{locale}/translations", %{ text: text, validation: "false" })
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
    # 200 if it exists; 404 (with a "[]" response body) if it doesn't.
    get("/strings?filters[key]=#{key}")
    |> verify_one_of_response_codes([ 200, 404 ])
    |> parse_body
  end

  defp parse_body(response) do
    JSON.parse(response.body)
  end

  defp verify_one_of_response_codes(response, codes) do
    unless Enum.member?(codes, response.status_code) do
      raise "Unexpected response: #{inspect(response)}"
    end

    response
  end

  defp verify_response_code(response, code) do
    if response.status_code != code do
      raise "Unexpected response: #{inspect(response)}"
    end

    response
  end

  defp get(path), do: Endpoint.get(path)
  defp post(path, data), do: Endpoint.post(path, data)
  defp delete(path), do: Endpoint.delete(path)
end
