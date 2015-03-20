use Mix.Config

config :content_translator, ContentTranslator.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  cache_static_lookup: false,
  translation_api: ContentTranslator.WtiTranslationApi,
  auth_token: "secret-token",
  redis_connection_string: "redis://localhost:6379/0"

# Enables code reloading for development
config :phoenix, :code_reloader, true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
