defmodule Katabot.Parser do
  @moduledoc """
  This module can
  """

  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_info({:parse, update = %{"update_id" => update_id}}, last_update_id) do
    if (last_update_id == nil || update_id > last_update_id) do

    end
    {:noreply, update_id}
  end
end