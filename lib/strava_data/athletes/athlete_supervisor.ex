defmodule StravaData.Athletes.AthleteSupervisor do
  alias Task.Supervisor

  alias StravaData.Athletes.Athlete

  def gather_athlete_data(%Athlete{} = athlete) do
    opts = [restart: :transient]

    Supervisor.start_child(
      __MODULE__,
      StravaData.Athletes.AthleteWorker,
      :gather_athlete_data,
      [athlete],
      opts
    )
  end

  def process_activity_data(%Athlete{} = athlete, activity_data) do
    opts = [restart: :transient]

    Supervisor.start_child(
      __MODULE__,
      StravaData.Athletes.AthleteWorker,
      :process_activity_data,
      [athlete, activity_data],
      opts
    )
  end
end
