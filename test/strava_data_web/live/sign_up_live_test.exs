defmodule StravaDataWeb.SignUpLiveTest do
  use StravaDataWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, view, disconnected_html} = live(conn, Routes.sign_up_path(conn, :index))

    auth_path = Routes.auth_path(conn, :auth)

    assert disconnected_html =~ "Sign Up"
    assert disconnected_html =~ "a href=\"#{auth_path}\""

    assert render(view) =~ "Sign Up"

    assert view
           |> element("a[href=\"#{auth_path}\"]")
           |> has_element?()
  end
end
