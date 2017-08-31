defmodule Katabot.Application do
  @moduledoc false

  use Application
  alias Plug.Adapters.Cowboy

  @webhook_settings Application.get_env(:katabot, :webhook)
  @init %{token: @webhook_settings[:secret_token], parser: Katabot.Parser}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Cowboy.child_spec(
        @webhook_settings[:protocol],
        Katabot.Webhook,
        @init,
        @webhook_settings[:options]),
      worker(Katabot.CryptoCompare, []),
      worker(Katabot.Parser, [Nadia, Katabot.CryptoCompare]),
      supervisor(Task.Supervisor, [
          [name: Katabot.SendResponseSupervisor, restart: :temporary]
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: Katabot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
