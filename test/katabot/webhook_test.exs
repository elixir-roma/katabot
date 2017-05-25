defmodule Katabot.WebhookTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @sample Poison.encode! %{test: "test"}

  test "It should receive telegram updates" do

    opts = Katabot.Webhook.init(token: "test", parser: self())

    conn = conn(:post, "/test", @sample)
    |> Katabot.Webhook.call(opts)

    assert conn.state == :sent
    assert conn.status == 204

   assert_receive({:parse, %{"test" => "test"}})
  end

  test "It should not respond to other routes" do

    opts = Katabot.Webhook.init(token: "test", parser: self())

    assert_raise Katabot.Webhook.ForbiddenRequestError, fn ->
      conn(:post, "/fail", @sample)
      |> Katabot.Webhook.call(opts)
    end
  end
end
