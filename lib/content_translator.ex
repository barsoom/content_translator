defmodule ContentTranslator do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.add_backend ErrorReportingBackend

    children = [
      supervisor(ContentTranslator.Endpoint, []),
      worker(ContentTranslator.BackgroundJob, []),
      worker(ContentTranslator.TranslationService, []),
      worker(ContentTranslator.ClientApp, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ContentTranslator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ContentTranslator.Endpoint.config_change(changed, removed)
    :ok
  end
end
