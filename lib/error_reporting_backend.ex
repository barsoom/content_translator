# Very basic error reporting backend.

# There isn't any honeybadger plugin for the elixir Logger as far
# as I have found. This is good enough for our purposes.

defmodule ErrorReportingBackend do
  use GenEvent

  def init(_) do
    {:ok, self}
  end

  def handle_event({:error, _pid, event}, state) do
    { Logger, error_message, _date_and_time, _pid } = event

    error_message = inspect(error_message)

    report_error(error_message)

    {:ok, state}
  end

  def handle_event({_other, _pid, _event}, state) do
    {:ok, state}
  end

  defp report_error(error_message) do
    error_message
    |> build_payload
    |> send_to_honeybadger
  end

  defp build_payload(error_message) do
    %{
      notifier: %{
        name: "ErrorReportingBackend",
        url: "",
        version: "1.0"
      },
      error: %{
        class: "Error",
        message: error_message
      },
      server: %{
        environment_name: Mix.env
      }
    }
  end

  defp send_to_honeybadger(payload) do
    response = HTTPotion.post("https://api.honeybadger.io/v1/notices",
      [
        body: JSON.encode(payload),
        headers: [
          "Content-Type": "application/json; charset=utf-8",
          "X-API-Key": Config.honeybadger_api_key,
          "Accept": "application/json"
        ]
      ]
    )

    if response.status_code != 201 do
      raise "Unknown response from honeybadger: #{inspect(response)}"
    end
  end
end