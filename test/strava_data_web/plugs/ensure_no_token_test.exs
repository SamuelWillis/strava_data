defmodule StravaDataWeb.Plugs.EnsureNoTokenTest do
  use StravaDataWeb.ConnCase, async: true

  alias StravaDataWeb.Plugs.EnsureNoToken

  test "redirects to / when token in session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{token: "fake-token"})
      |> EnsureNoToken.call(%{})

    assert conn.halted

    assert redirected_to(conn, 302) == "/"
  end

  test "allows conn without token in session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> EnsureNoToken.call(%{})

    refute conn.halted
  end
end
