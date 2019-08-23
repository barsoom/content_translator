defmodule ContentTranslator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :content_translator,
      version: "1.0.0",
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ContentTranslator, []},
      applications: [:phoenix, :phoenix_html, :cowboy, :logger, :httpotion, :honeybadger, :toniq]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:phoenix, "~> 1.0"},
      {:phoenix_html, "~> 2.1"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:cowboy, "~> 1.0"},

      # a http client and its dependency
      # NOTE: Upgrading to httpotion 3.1.1 and ibrowse v4.4.1 in 2f2c1f472a0b8e0f56ecb4c89cc310eecf9a88af broke the sync from WTI to Auctionet without tests failing! Beware.
      {:httpotion, "~> 2.0.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2", override: true},
      {:honeybadger, "~> 0.12"},
      {:exredis, ">= 0.1.3"},
      {:toniq, "~> 1.0"}
    ]
  end
end
