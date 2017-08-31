use Mix.Config

config :katabot, :webhook,
  protocol: :http,
  options: [port: 8080],
  secret_token: "wh"

  config :logger,
    level: :debug,
    truncate: 4096
