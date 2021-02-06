defmodule StravaData.Athletes.AthleteWorkerTest do
  import Ecto.Query, only: [from: 2]
  use StravaData.DataCase, async: true

  alias StravaData.Athletes.Activity
  alias StravaData.Athletes.AthleteWorker

  setup do
    athlete = insert(:athlete)
    Phoenix.PubSub.subscribe(StravaData.PubSub, "athlete:#{athlete.id}")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(StravaData.PubSub, "athlete:#{athlete.id}")
    end)

    %{athlete: athlete}
  end

  describe "process_activity_data/2" do
    test "processes a list of activities", %{athlete: athlete} do
      %{id: athlete_id} = athlete
      data = build_activity_data()

      AthleteWorker.process_activity_data(athlete, data)

      assert [
               %Activity{},
               %Activity{}
             ] = StravaData.Repo.all(from a in Activity, where: a.athlete_id == ^athlete_id)
    end
  end

  defp build_activity_data() do
    [
      %{
        "id" => 1234,
        "name" => "Big Ride",
        "start_date_local" => "2021-03-14T09:29:53Z",
        "distance" => 10_000.0,
        "moving_time" => 420,
        "elapsed_time" => 420,
        "total_elevation_gain" => 1000.0,
        "type" => "Ride",
        "achievement_count" => 10,
        "average_speed" => 4.2,
        "max_speed" => 42.0
      },
      %{
        "id" => 5678,
        "name" => "Big Ride 2",
        "start_date_local" => "2021-03-14T09:29:53Z",
        "distance" => 420_000.0,
        "moving_time" => 420,
        "elapsed_time" => 420,
        "total_elevation_gain" => 4200.0,
        "type" => "Ride",
        "achievement_count" => 420,
        "average_speed" => 4.2,
        "max_speed" => 42.0
      }
    ]
  end
end
