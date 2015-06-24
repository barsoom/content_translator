defmodule ContentTranslator do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    redis_client = Exredis.start_using_connection_string(Config.redis_connection_string)
    Process.register(redis_client, :redis)

    # TODO: do this in a cleaner way, preferabbly after each redis test
    if Mix.env == :test do
      Exredis.query(redis_client, [ "FLUSHDB" ])
    end

    children = [
      supervisor(ContentTranslator.Endpoint, []),
      worker(ContentTranslator.BackgroundJob, []),
      worker(ContentTranslator.TranslationService, []),
      worker(ContentTranslator.ClientApp, []),
    ]

    # TODO: do a cleaner "after_app_boot" callback
    spawn fn ->
      :timer.sleep 3000
      ContentTranslator.BackgroundJob.run_previously_enqueued_jobs
    end

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
