defmodule Katabot.ParserTest do
  use ExUnit.Case, async: true

  alias Katabot.Parser

  @eth_message %{"message" => %{"chat" => %{"first_name" => "Claudio", "id" => 343639865,
    "type" => "private"}, "date" => 1495847837,
    "from" => %{"first_name" => "Claudio", "id" => 343639865,
      "language_code" => "it"}, "message_id" => 6, "text" => "situazione eth"},
    "update_id" => 152205571}

  test "it should ask for eth situation" do
    defmodule FakeNadiaEth do
      def send_message(_, message) do
        assert message == "L'ethereum al momento è a 0.07096 BTC, 293.92 USD, 249.64 EUR"
        {:ok, "yeee"}
      end
    end
    defmodule FakeCriptoCompare do
      def get_eth_status do
        %{"BTC" => 0.07096, "EUR" => 249.64, "USD" => 293.92}
      end
    end

    {:ok, subject_pid} = Parser.start_link(FakeNadiaEth, FakeCriptoCompare)
    send subject_pid, {:parse, @eth_message}
  end

end
