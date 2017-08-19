defmodule Katabot.Parser do
  @moduledoc """
  This module answer to the command *situazione (btc|eth)*
  """

  use GenServer

  require Logger

  def start_link(nadia) do
    GenServer.start_link(__MODULE__, %{nadia: nadia}, name: __MODULE__)
  end

  def init(%{nadia: nadia}) do
    {:ok, {nil, nadia}}
  end

  def handle_info({:parse, update = %{"update_id" => update_id}}, {last_update_id, nadia}) do
    if last_update_id == nil || update_id > last_update_id do
      text = update["message"]["text"]
      cond do
        Regex.match? ~r/situazione\s.*(eth|ethereum)/iu, text ->
          report_eth_situation nadia, update["message"]["chat"]["id"]
        Regex.match? ~r/situazione\s.*(btc|bitcoin)/iu, text ->
          report_btc_situation nadia, update["message"]["chat"]["id"]
        true ->
          nil
      end
    end
    {:noreply, {update_id, nadia}}
  end

  defp report_eth_situation(nadia, chat) do
    msg = case HTTPoison.get("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = body
        |> Poison.decode!()
        "L'ethereum al momento è a #{body["BTC"]} BTC, #{body["USD"]} USD, #{body["EUR"]} EUR"
      _ ->
        "Al momento non mi è possibile reperire l'inforazione, riprova piu tardi!"
    end

    send_msg(nadia, chat, msg)
  end

  defp report_btc_situation(nadia, chat) do
    msg = case HTTPoison.get("https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=ETH,USD,EUR") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = body
               |> Poison.decode!
        "Il bitcoin al momento è a #{body["ETH"]} ETH, #{body["USD"]} USD, #{body["EUR"]} EUR"
      _ ->
        "Al momento non mi è possibile reperire l'inforazione, riprova piu tardi!"
    end
    send_msg(nadia, chat, msg)
  end

  defp send_msg(nadia, chat, msg) do
    case nadia.send_message(chat, msg) do
      {:ok, _result} ->
        :ok
      {:error, _} ->
        :wait
    end
  end
end
