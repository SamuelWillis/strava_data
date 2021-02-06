defmodule StravaDataWeb.Plugs.EnsureToken do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :token) do
      token when is_binary(token) ->
        conn

      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/signup")
        |> halt()
    end
  end
end
