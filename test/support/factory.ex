defmodule StravaData.Factory do
  alias StravaData.Repo

  def build(:athlete) do
    %StravaData.Athletes.Athlete{
      first_name: "Usain",
      last_name: "Bolt",
      username: "lightning_bolt",
      profile_picture: "http://usain.bolt/picture",
      strava_id: 1234
    }
  end

  def build(:athlete_with_activity) do
    attrs = %{
      activities: [
        %{
          strava_id: 1234,
          name: "Big Ride",
          start_date_local: DateTime.truncate(DateTime.utc_now(), :second),
          distance: 10_000.0,
          moving_time: 420,
          elapsed_time: 420,
          total_elevation_gain: 1000.0,
          type: "Ride",
          achievement_count: 10,
          average_speed: 4.2,
          max_speed: 42.0
        }
      ]
    }

    build(:athlete, attrs)
  end

  def build(:athlete_with_gear) do
    attrs = %{
      gear: [
        %{
          name: "SB150",
          primary: true,
          strava_id: "b1234"
        }
      ]
    }

    build(:athlete, attrs)
  end

  def build(:athlete_with_tokens) do
    attrs = %{
      access_token: %StravaData.Auth.AccessToken{
        token: "fake_refresh_token",
        token_type: "Bearer",
        expires_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      refresh_token: %StravaData.Auth.RefreshToken{
        token: "fake_refresh_token"
      }
    }

    build(:athlete, attrs)
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
