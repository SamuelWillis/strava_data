defmodule StravaData.Athletes.AthleteWorker do
  alias StravaData.Api
  alias StravaData.Athletes
  alias StravaData.Athletes.Athlete
  alias StravaData.Athletes.AthleteSupervisor

  def gather_athlete_data(%Athlete{} = athlete) do
    athlete = StravaData.Repo.preload(athlete, [:activities, :gear])
    athlete_data = get_athlete_and_gear_data(athlete)

    {:ok, athlete} = update_athlete(athlete, athlete_data)

    {:ok, athlete} = update_athlete_gear(athlete, athlete_data)

    update_athlete_activities(athlete)
  end

  defp get_athlete_and_gear_data(athlete) do
    task = Task.async(fn -> Api.get_authenticated_athlete!(athlete) end)

    Task.await(task)
  end

  defp update_athlete(athlete, data) do
    athlete_attrs = cast_athlete_attrs_from_api(data)
    Athletes.update_athlete(athlete, athlete_attrs)
  end

  defp update_athlete_gear(athlete, data) do
    gear_attrs =
      data
      |> cast_gear_attrs_from_api()
      |> Enum.map(fn attrs ->
        case Enum.find(athlete.gear, &(&1.strava_id == attrs["strava_id"])) do
          nil -> attrs
          matched_gear -> Map.put(attrs, "id", matched_gear.id)
        end
      end)

    Athletes.update_athlete_gear(athlete, gear_attrs)
  end

  def update_athlete_activities(athlete, page \\ 1) do
    task = Task.async(fn -> Api.get_activities_page!(athlete, page: page) end)

    case Task.await(task, 6000) do
      results when results != [] ->
        AthleteSupervisor.process_activity_data(athlete, results)

        update_athlete_activities(athlete, page + 1)

      [] ->
        page
    end
  end

  def process_activity_data(athlete, data) when is_list(data) do
    athlete = StravaData.Repo.preload(athlete, [:activities, :gear])

    activities_attrs =
      data
      |> Stream.map(&cast_from_api/1)
      |> Stream.map(fn attrs ->
        case Enum.find(athlete.gear, &(&1.strava_id == attrs["gear_id"])) do
          nil -> attrs
          matched_gear -> Map.put(attrs, "gear_id", matched_gear.id)
        end
      end)
      |> Enum.map(fn attrs ->
        case Enum.find(athlete.activities, &(&1.strava_id == attrs["strava_id"])) do
          nil -> attrs
          matched_activity -> Map.put(attrs, :id, matched_activity.id)
        end
      end)

    Athletes.update_athlete_activities(athlete, activities_attrs)
  end

  defp cast_athlete_attrs_from_api(%{
         "id" => strava_id,
         "firstname" => first_name,
         "lastname" => last_name,
         "username" => username,
         "profile_medium" => profile_picture
       }) do
    %{
      strava_id: strava_id,
      first_name: first_name,
      last_name: last_name,
      username: username,
      profile_medium: profile_picture
    }
  end

  defp cast_gear_attrs_from_api(%{"bikes" => bikes, "shoes" => shoes}) do
    []
    |> cast_gear_attrs_from_api(bikes)
    |> cast_gear_attrs_from_api(shoes)
  end

  defp cast_gear_attrs_from_api([], [gear_data | tail]),
    do: cast_gear_attrs_from_api([cast_gear(gear_data)], tail)

  defp cast_gear_attrs_from_api(gear, [gear_data | tail]),
    do: cast_gear_attrs_from_api([cast_gear(gear_data) | gear], tail)

  defp cast_gear_attrs_from_api(gear, []), do: gear

  defp cast_gear(%{
         "id" => strava_id,
         "name" => name,
         "primary" => primary
       }) do
    %{
      strava_id: strava_id,
      name: name,
      primary: primary
    }
  end

  def cast_from_api(%{
        "id" => id,
        "name" => name,
        "start_date_local" => start_date_local,
        "distance" => distance,
        "moving_time" => moving_time,
        "elapsed_time" => elapsed_time,
        "total_elevation_gain" => total_elevation_gain,
        "type" => type,
        "achievement_count" => achievement_count,
        "average_speed" => average_speed,
        "max_speed" => max_speed
      }) do
    {:ok, start_date_local, _} = DateTime.from_iso8601(start_date_local)

    %{
      strava_id: id,
      name: name,
      start_date_local: start_date_local,
      distance: distance,
      moving_time: moving_time,
      elapsed_time: elapsed_time,
      total_elevation_gain: total_elevation_gain,
      type: type,
      achievement_count: achievement_count,
      average_speed: average_speed,
      max_speed: max_speed
    }
  end
end
