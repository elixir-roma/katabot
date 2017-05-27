defmodule Katabot.Application do
  @moduledoc false

  use Application

  @webhook_settings Application.get_env(:katabot, :webhook)
  @init %{token: @webhook_settings[:secret_token], parser: Katabot.Parser}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(
        @webhook_settings[:protocol],
        Katabot.Webhook,
        @init,
        @webhook_settings[:options]),
      worker(Katabot.Parser, [])
    ]

    opts = [strategy: :one_for_one, name: Katabot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
