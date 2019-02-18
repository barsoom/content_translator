use Mix.Config

config :content_translator, ContentTranslator.Endpoint,
  http: [port: System.get_env("PORT") || 4001],
  translation_api: ContentTranslator.FakeTranslationApi,
  client_app_api: ContentTranslator.FakeClientAppApi,
  wti_project_id: 1234,
  auth_token: "secret-token"

# Auctionet developers use https://github.com/barsoom/devbox to e.g. get dependencies from dev.yml.
redis_port =
  if System.get_env("DEVBOX") do
    System.cmd("service_port", [ "redis" ]) |> elem(0) |> String.trim()
  else
    6379
  end

config :toniq, redis_url: (System.get_env("REDIS_URL") || "redis://localhost:#{redis_port}") <> "/1"

# Print only warnings and errors during test
config :logger, level: :warn
