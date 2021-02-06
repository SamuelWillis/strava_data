defmodule StravaDataWeb.AuthController do
  use StravaDataWeb, :controller

  alias StravaData.Athletes
  alias StravaData.Api
  alias Phoenix.Token

  def auth(conn, _params) do
    redirect(conn, external: Api.authorize_url!())
  end

  def callback(conn, %{"code" => code}) do
    %Athletes.Athlete{} = athlete = Athletes.initialize_athlete!(code: code)

    token = Token.sign(StravaDataWeb.Endpoint, "athlete auth", athlete.id)

    Athletes.start_gather_athlete_data(athlete)

    conn
    |> fetch_session()
    |> put_session(:token, token)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def callback(conn, _params) do
    redirect(conn, to: Routes.sign_up_path(conn, :index))
  end
end
