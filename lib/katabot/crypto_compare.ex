defmodule Katabot.CryptoCompare do
  @moduledoc """
  This module will store criptocurrencies status and update it every second
  """

  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def get_eth_status, do: GenServer.call(__MODULE__, :eth)
  def get_btc_status, do: GenServer.call(__MODULE__, :btc)

  defp get_status!, do: %{eth: ask_for_eth(), btc: ask_for_btc()}

  defp ask_for_eth do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR")
    body
    |> Poison.decode!()
  end

  defp ask_for_btc do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get("https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=ETH,USD,EUR")
    body
    |> Poison.decode!()
  end

  def init(_) do
    Process.send_after self(), :update, 1_000
    {:ok, get_status!()}
  end

  def handle_info(:update, old_state) do
    Process.send_after self(), :update, 1_000
    try do
      {:noreply, get_status!()}
    rescue
      _ ->
        {:noreply, old_state}
      end
  end

  def handle_call(:eth, _from, %{eth: eth} = state), do: {:reply, eth, state}
  def handle_call(:btc, _from, %{btc: btc} = state), do: {:reply, btc, state}
end
