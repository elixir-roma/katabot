defmodule Katabot.ParserTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Katabot.Parser

  @eth_message %{"message" => %{"chat" => %{"first_name" => "Claudio", "id" => 343639865,
    "type" => "private"}, "date" => 1495847837,
    "from" => %{"first_name" => "Claudio", "id" => 343639865,
      "language_code" => "it"}, "message_id" => 6, "text" => "situazione eth"},
    "update_id" => 152205571}
  @btc_message %{"message" => %{"chat" => %{"first_name" => "Claudio", "id" => 343639865,
    "type" => "private"}, "date" => 1495847837,
    "from" => %{"first_name" => "Claudio", "id" => 343639865,
      "language_code" => "it"}, "message_id" => 6, "text" => "situazione bitcoin"},
    "update_id" => 152205572}

  setup_all do
    HTTPoison.start
    :ok
  end

  test "it should ask for eth situation" do
    use_cassette "eth" do
      defmodule FakeNadiaEth do
        def send_message(_, message) do
          assert message == "L'ethereum al momento è a 0.07096 BTC, 293.92 USD, 249.64 EUR"
          {:ok, "yeee"}
        end
      end

      {:ok, subject_pid} = Parser.start_link(FakeNadiaEth)
      send subject_pid, {:parse, @eth_message}
    end
  end

  test "it should ask for btc situation" do
    use_cassette "btc" do
      defmodule FakeNadiaBtc do
        def send_message(_, message) do
          assert message == "Il bitcoin al momento è a 14.09 ETH, 4140.04 USD, 3552.41 EUR"
          {:ok, "yeee"}
        end
      end

      {:ok, subject_pid} = Parser.start_link(FakeNadiaBtc)
      send subject_pid, {:parse, @btc_message}
    end
  end
end
