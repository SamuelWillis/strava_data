defmodule StravaDataWeb.Plugs.EnsureTokenTest do
  use StravaDataWeb.ConnCase, async: true

  alias StravaDataWeb.Plugs.EnsureToken

  test "redirects when no token in session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> EnsureToken.call(%{})

    assert conn.halted

    assert redirected_to(conn, 302) == "/signup"
  end

  test "allows conn with token in session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{token: "fake-token"})
      |> EnsureToken.call(%{})

    refute conn.halted
  end
end
