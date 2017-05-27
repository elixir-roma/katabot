use Mix.Config

config :katabot, :webhook,
  protocol: :https,
  options: [port: 8080,
            otp_app: :katabot,
            keyfile: "priv/ssl/private.key",
            certfile: "priv/ssl/pubkey.pem"]

