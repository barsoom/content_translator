defmodule ContentTranslator.ClientAppApi do
  def update(attributes) do
    HTTPotion.post(
      Config.client_app_webhook_url,
      [
        body: "payload=#{JSON.encode(attributes)}"
      ]
    )
    |> verify_response_code(200)
  end

  defp verify_response_code(response, code) do
    if response.status_code != code do
      raise "Unexpected response: #{inspect(response)}"
    end

    response
  end
end
