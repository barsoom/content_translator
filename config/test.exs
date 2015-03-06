use Mix.Config

config :content_translator, ContentTranslator.Endpoint,
  http: [port: System.get_env("PORT") || 4001],
  translation_api: ContentTranslator.FakeTranslationApi

# Print only warnings and errors during test
config :logger, level: :warn
