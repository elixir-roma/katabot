defmodule Katabot.Parser do
  @moduledoc """
  This module answer to the command *situazione (btc|eth)*
  """

  use GenServer

  require Logger

  def start_link(nadia, cripto_compare) do
    GenServer.start_link(
      __MODULE__,
      {nadia, cripto_compare},
      name: __MODULE__
    )
  end

  def init({nadia, cripto_compare}) do
    {:ok, {nil, nadia, cripto_compare}}
  end

  def handle_info({_from, :delivered}, status), do: {:noreply, status}
  def handle_info({:DOWN, _, _, _, _}, status), do: {:noreply, status}

  def handle_info({:parse, update = %{"update_id" => update_id}},
    {last_update_id, nadia, cripto_compare}) do
    if last_update_id == nil || update_id > last_update_id do
      text = update["message"]["text"]
      cond do
        Regex.match? ~r/situazione\s.*(eth|ethereum)/iu, text ->
          report_eth_situation(
            nadia,
            update["message"]["chat"]["id"],
            cripto_compare.get_eth_status()
          )
        Regex.match? ~r/situazione\s.*(btc|bitcoin)/iu, text ->
          report_btc_situation(
            nadia,
            update["message"]["chat"]["id"],
            cripto_compare.get_btc_status()
          )
        true ->
          nil
      end
    end
    {:noreply, {update_id, nadia, cripto_compare}}
  end

  defp report_eth_situation(nadia, chat, status) do
    Task.Supervisor.async(Katabot.SendResponseSupervisor, fn ->
      send_msg(
        nadia,
        chat,
        "L'ethereum al momento è a #{status["BTC"]} BTC, #{status["USD"]} USD, #{status["EUR"]} EUR")
    end)
  end

  defp report_btc_situation(nadia, chat, status) do
    Task.Supervisor.async(Katabot.SendResponseSupervisor, fn ->
      send_msg(
        nadia,
        chat,
        "Il bitcoin al momento è a #{status["ETH"]} ETH, #{status["USD"]} USD, #{status["EUR"]} EUR")
    end)
  end

  defp send_msg(nadia, chat, msg) do
    case nadia.send_message(chat, msg) do
      {:ok, _result} ->
        :delivered
      {:error, error} ->
        Logger.error(error)
        send_msg(nadia, chat, msg)
    end
  end
end
