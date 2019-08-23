use Mix.Config

config :content_translator, ContentTranslator.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  cache_static_lookup: false,
  translation_api: ContentTranslator.WtiTranslationApi,
  client_app_api: ContentTranslator.ClientAppApi,
  auth_token: "secret-token",
  wti_project_token: System.get_env("WTI_PROJECT_TOKEN"),
  client_app_webhook_url: System.get_env("CLIENT_APP_WEBHOOK_URL"),
  wti_project_id: System.get_env("WTI_PROJECT_ID")

# Auctionet developers use https://github.com/barsoom/devbox to e.g. get dependencies from dev.yml.
redis_port =
  if System.get_env("DEVBOX") do
    System.cmd("service_port", ["redis"]) |> elem(0) |> String.trim()
  else
    6379
  end

config :toniq, redis_url: System.get_env("REDIS_URL") || "redis://localhost:#{redis_port}/0"

# Enables code reloading for development
config :phoenix, :code_reloader, true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
