defmodule StravaDataWeb.Plugs.EnsureNoToken do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :token) do
      token when is_binary(token) ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      nil ->
        conn
    end
  end
end
