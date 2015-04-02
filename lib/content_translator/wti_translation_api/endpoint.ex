defmodule ContentTranslator.WtiTranslationApi.Endpoint do
  def get(path), do: api_call(:get, path)
  def post(path, data), do: api_call(:post, path, data)
  def delete(path), do: api_call(:delete, path)

  defp api_call(method, path, data \\ %{}) do
    HTTPotion.request(method,
      "https://webtranslateit.com/api/projects/#{project_token}/#{path}",
      [
        body: JSON.encode(data),
        headers: [ "Content-Type": "application/json" ]
      ]
    )
  end

  defp project_token do
    Config.wti_project_token
  end
end
