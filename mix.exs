defmodule Katabot.Mixfile do
  use Mix.Project

  def project do
    [app: :katabot,
     version: "0.1.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     preferred_cli_env: [vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test],
     aliases: aliases()]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Katabot.Application, []}]
  end

  defp deps do
    [{:edeliver, "~> 1.4.4"},
     {:distillery, ">= 0.8.0", warn_missing: false},
     {:poison, "~> 3.0"},
     {:exvcr, "~> 0.8", only: :test, runtime: false},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:httpoison, "~> 0.13"},
     {:nadia, "~> 0.4.2"},
     {:cowboy, "~> 1.1.2"},
     {:plug, "~> 1.3.5"}]
  end
end
