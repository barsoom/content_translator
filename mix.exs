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
     applications: [:phoenix, :cowboy, :logger, :httpotion]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
     {:phoenix, "~> 0.10.0"},
     {:cowboy, "~> 1.0"},
     {:exredis, ">= 0.1.1"},

     # a http client and it's and dependency
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1"},
     {:httpotion, "~> 2.0.0"},
    ]
  end
end
