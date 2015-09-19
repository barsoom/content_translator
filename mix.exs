defmodule ContentTranslator.Mixfile do
  use Mix.Project

  def project do
    [app: :content_translator,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {ContentTranslator, []},
     applications: [:phoenix, :cowboy, :logger, :httpotion, :honeybadger, :toniq]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
     {:phoenix, "~> 0.10.0"},
     {:cowboy, "~> 1.0"},

     # a http client and it's and dependency
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2", override: true},
     {:httpotion, "~> 2.0.0"},

     {:honeybadger, github: "joakimk/honeybadger"},
     {:toniq, github: "joakimk/toniq"},
    ]
  end
end
