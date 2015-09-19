# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :content_translator, ContentTranslator.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/IqbN1/dR1PVfQmW5bLUGeQHkfEUStbOIaRf8g1ZxOMuwz5lLB080jJuZFCsIkOg",
  debug_errors: false,
  pubsub: [
    name: Phoenix.PubSub,
    adapter: Phoenix.PubSub.PG2
  ]

# Ensure we don't collide with any other app using toniq. In development
# it's very likely you're using the same redis server for multiple apps,
# and it doesn't hurt to prefix in other envs as well.
config :toniq, redis_key_prefix: "content_translator:toniq"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
