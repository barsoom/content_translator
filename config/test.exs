use Mix.Config

config :content_translator, ContentTranslator.Endpoint,
  http: [port: System.get_env("PORT") || 4001],
  translation_api: ContentTranslator.FakeTranslationApi,
  client_app_api: ContentTranslator.FakeClientAppApi,
  wti_project_id: 1234,
  auth_token: "secret-token"

config :toniq, redis_url: (System.get_env("REDIS_URL") || "redis://localhost:6379") <> "/1"

# Print only warnings and errors during test
config :logger, level: :warn
