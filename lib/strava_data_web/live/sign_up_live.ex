defmodule StravaDataWeb.SignUpLive do
  use StravaDataWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Sign Up</h1>
    <a href="<%= Routes.auth_path(@socket, :auth) %>">
    <img
      src="<%= Routes.static_path(@socket, "/images/btn_strava_connectwith_orange.svg") %>"
      alt="Connect with Strava"
    />
    </a>
    """
  end
end
