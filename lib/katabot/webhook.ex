defmodule Katabot.Webhook do
  @moduledoc """
  This module is a webhook able to handle telegram updates
  """

  import Plug.Conn

  defmodule ForbiddenRequestError do
    @moduledoc """
    Error raised when the route doesn't match the initial token
    """

    defexception message: "Forbidden", plug_status: 403
  end

  def init(options), do: options

  def call(conn = %Plug.Conn{request_path: path}, opts) do
    unless String.strip(path, ?/) == opts[:token] do
      raise ForbiddenRequestError
    end

    conn
    |> parse_updates(opts[:parser])
    |> send_resp(204, "")
  end

  defp parse_updates(conn, parser) do
         {:ok, data, _none} = Plug.Conn.read_body(conn)
         data = Poison.decode! data

         send parser, {:parse, data}

      conn
  end
end
