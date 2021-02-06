defmodule StravaData.Athletes.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "activities" do
    field :strava_id, :integer
    field :name, :string
    field :start_date_local, :utc_datetime
    field :distance, :float
    field :moving_time, :integer
    field :elapsed_time, :integer
    field :total_elevation_gain, :float
    field :type, :string
    field :achievement_count, :integer
    field :average_speed, :float
    field :max_speed, :float

    belongs_to :athlete, StravaData.Athletes.Athlete, type: :binary_id
    belongs_to :gear, StravaData.Athletes.Gear, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [
      :athlete_id,
      :strava_id,
      :name,
      :start_date_local,
      :distance,
      :moving_time,
      :elapsed_time,
      :total_elevation_gain,
      :type,
      :achievement_count,
      :average_speed,
      :max_speed
    ])
    |> unique_constraint(:strava_id)
    |> cast_assoc(:gear, required: false)
    |> validate_required([
      :athlete_id,
      :strava_id,
      :name,
      :start_date_local,
      :distance,
      :moving_time,
      :elapsed_time,
      :total_elevation_gain,
      :type,
      :average_speed,
      :max_speed
    ])
  end
end
