defmodule StravaData.AthletesTest do
  use StravaData.DataCase, async: true

  alias StravaData.Athletes
  alias StravaData.Athletes.Activity
  alias StravaData.Athletes.Athlete
  alias StravaData.Athletes.Gear
  alias StravaData.Auth

  describe "get_athlete/1" do
    test "returns athlete with tokens loaded" do
      %Athlete{id: id} = insert(:athlete_with_tokens)

      assert %Athlete{id: ^id} = athlete = Athletes.get_athlete(id)
      assert %Auth.AccessToken{} = athlete.access_token
      assert %Auth.RefreshToken{} = athlete.refresh_token
    end

    test "returns nil for no athlete" do
      refute Athletes.get_athlete(Ecto.UUID.generate())
    end
  end

  describe "get_activities_for/1" do
    test "returns athlete activities" do
      %{id: athlete_id} = athlete = insert(:athlete_with_activity)

      assert [activity] = Athletes.get_activities_for(athlete)

      assert %Activity{
               athlete_id: ^athlete_id
             } = activity
    end
  end

  describe "update_athlete/2" do
    test "updates athlete with attrs" do
      athlete = insert(:athlete)

      attrs = %{
        first_name: "Anton",
        last_name: "Krupicka",
        username: "anton"
      }

      assert {:ok, %Athlete{} = updated_athlete} = Athletes.update_athlete(athlete, attrs)

      assert updated_athlete.id == athlete.id
      assert updated_athlete.first_name == attrs.first_name
      assert updated_athlete.last_name == attrs.last_name
      assert updated_athlete.username == attrs.username
    end
  end

  describe "update_athlete_gear/2" do
    test "inserts new gear" do
      athlete = insert(:athlete)

      gear_attrs = [
        %{
          strava_id: "b1234",
          name: "Yeti SB150",
          primary: true
        }
      ]

      assert {:ok, athlete} = Athletes.update_athlete_gear(athlete, gear_attrs)

      assert [%Gear{}] = athlete.gear
    end

    test "updates gear" do
      %{gear: [gear]} = athlete = insert(:athlete_with_gear)

      gear_attrs = [
        %{
          id: gear.id,
          name: "SB165",
          primary: false,
          strava_id: "b1234"
        }
      ]

      assert {:ok, athlete} = Athletes.update_athlete_gear(athlete, gear_attrs)

      assert [updated_gear] = athlete.gear

      assert updated_gear.name == "SB165"
      assert updated_gear.primary == false
      assert updated_gear.strava_id == "b1234"
    end

    test "deletes gear" do
      athlete = insert(:athlete_with_gear)

      assert {:ok, athlete} = Athletes.update_athlete_gear(athlete, [])

      assert [] = athlete.gear
    end

    test "inserts, updates, and deletes gear" do
      {:ok, athlete} =
        Repo.insert(%Athlete{
          strava_id: 1234,
          gear: [
            %{name: "SB165", primary: false, strava_id: "b1234"},
            %{name: "SB150", primary: true, strava_id: "b4321"}
          ]
        })

      %{gear: [gear | _]} = athlete

      gear_attrs = [
        %{
          name: "Naked",
          primary: true,
          strava_id: "b5678"
        },
        %{
          id: gear.id,
          name: "Big Comfy Couch Bike",
          primary: false
        }
      ]

      assert {:ok, athlete} = Athletes.update_athlete_gear(athlete, gear_attrs)

      assert [%Gear{}, %Gear{}] = athlete.gear
    end
  end

  describe "update_athlete_activities/2" do
    test "inserts activity" do
      athlete = insert(:athlete)

      attrs = [
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

      assert {:ok, %Athlete{} = athlete} = Athletes.update_athlete_activities(athlete, attrs)

      assert [%Activity{}] = athlete.activities
    end

    test "updates activity" do
      %{activities: [activity]} = athlete = insert(:athlete_with_activity)

      attrs = [
        %{
          id: activity.id,
          strava_id: 1234,
          name: "Updated Big Ride"
        }
      ]

      assert {:ok, %Athlete{} = athlete} = Athletes.update_athlete_activities(athlete, attrs)

      assert [updated_activity] = athlete.activities

      assert updated_activity.id == activity.id
      assert updated_activity.name == "Updated Big Ride"
    end

    test "deletes activity" do
      athlete = insert(:athlete_with_activity)

      assert {:ok, %Athlete{} = athlete} = Athletes.update_athlete_activities(athlete, [])

      assert [] = athlete.activities
    end

    test "inserts, updates, and deletes activities" do
      {:ok, start_date_local, _} = DateTime.from_iso8601("2021-03-14T09:29:53Z")

      {:ok, athlete} =
        Repo.insert(%Athlete{
          strava_id: 1234,
          activities: [
            %{
              strava_id: 1234,
              name: "Big Ride",
              start_date_local: start_date_local,
              distance: 10_000.0,
              moving_time: 420,
              elapsed_time: 420,
              total_elevation_gain: 1000.0,
              type: "Ride",
              achievement_count: 10,
              average_speed: 4.2,
              max_speed: 42.0
            },
            %{
              strava_id: 5678,
              name: "Little Ride",
              start_date_local: start_date_local,
              distance: 10.0,
              moving_time: 42,
              elapsed_time: 42,
              total_elevation_gain: 100.0,
              type: "Ride",
              achievement_count: 1,
              average_speed: 4.2,
              max_speed: 42.0
            }
          ]
        })

      %{activities: [activity | _]} = athlete

      activity_attrs = [
        %{
          strava_id: 4567,
          name: "Another Ride",
          start_date_local: start_date_local,
          distance: 10.0,
          moving_time: 42,
          elapsed_time: 42,
          total_elevation_gain: 100.0,
          type: "Ride",
          achievement_count: 1,
          average_speed: 4.2,
          max_speed: 42.0
        },
        %{
          id: activity.id,
          name: "Updated Big Ride"
        }
      ]

      assert {:ok, athlete} = Athletes.update_athlete_activities(athlete, activity_attrs)

      assert [%Activity{}, %Activity{}] = athlete.activities
    end
  end

  describe "insert_or_update_athlete!/1" do
    test "inserts a new athlete with tokens" do
      attrs = %{
        first_name: "Anton",
        last_name: "Krupicka",
        username: "anton",
        profile_picture: "https://anton.krupicka/picture",
        strava_id: 1234,
        refresh_token: %{
          token: "fake_refresh_token"
        },
        access_token: %{
          token: "fake_access_token",
          expires_at: NaiveDateTime.utc_now(),
          token_type: "Bearer"
        }
      }

      assert %Athlete{} = athlete = Athletes.insert_or_update_athlete!(attrs)
      assert %Auth.AccessToken{} = athlete.access_token
      assert %Auth.RefreshToken{} = athlete.refresh_token
    end

    test "updates existing athlete and tokens" do
      insert(:athlete_with_tokens)

      attrs = %{
        first_name: "Anton",
        last_name: "Krupicka",
        username: "anton",
        profile_picture: "https://anton.krupicka/picture",
        strava_id: 1234,
        refresh_token: %{
          token: "new_fake_refresh_token"
        },
        access_token: %{
          token: "new_fake_access_token",
          expires_at: NaiveDateTime.utc_now(),
          token_type: "Bearer"
        }
      }

      assert %Athlete{
               first_name: "Anton",
               last_name: "Krupicka",
               username: "anton",
               profile_picture: "https://anton.krupicka/picture",
               strava_id: 1234
             } = athlete = Athletes.insert_or_update_athlete!(attrs)

      assert %Auth.AccessToken{
               token: "new_fake_access_token"
             } = athlete.access_token

      assert %Auth.RefreshToken{
               token: "new_fake_refresh_token"
             } = athlete.refresh_token
    end
  end
end
