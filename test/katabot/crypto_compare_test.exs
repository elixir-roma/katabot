defmodule Katabot.CryptoCompareTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Katabot.CryptoCompare

  @eth_status %{"BTC" => 0.07096, "EUR" => 249.64, "USD" => 293.92}

  setup_all do
    HTTPoison.start
    :ok
  end

  test "It should ask at criptocompare for criptocurrencies state at bootstrap" do
    use_cassette "eth" do
      CryptoCompare.start_link()
      assert CryptoCompare.get_eth_status() == @eth_status
    end
  end
end
