defmodule StravaData.Athletes.Gear do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "gear" do
    field :name, :string
    field :primary, :boolean, default: false
    field :strava_id, :string

    belongs_to :athlete, StravaData.Athletes.Athlete, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(gear, attrs) do
    gear
    |> cast(attrs, [:athlete_id, :strava_id, :name, :primary])
    |> foreign_key_constraint(:athlete_id)
    |> unique_constraint(:strava_id)
    |> validate_required([:strava_id, :name])
  end
end
