use Mix.Config

config :nadia,
       recv_timeout: 10

import_config "config.priv.exs"
import_config "#{Mix.env}.exs"

