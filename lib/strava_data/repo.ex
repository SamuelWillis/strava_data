defmodule StravaData.Repo do
  use Ecto.Repo,
    otp_app: :strava_data,
    adapter: Ecto.Adapters.Postgres
end
