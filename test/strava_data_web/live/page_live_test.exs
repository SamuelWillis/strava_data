defmodule StravaDataWeb.PageLiveTest do
  use StravaDataWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :insert_athlete_and_set_session_token

  test "disconnected and connected render", %{conn: conn, athlete: athlete} do
    {:ok, page_live, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ "Welcome #{athlete.first_name}"
    assert render(page_live) =~ "Welcome #{athlete.first_name}"
  end
end
