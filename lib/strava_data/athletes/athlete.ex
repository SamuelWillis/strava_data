defmodule StravaData.Athletes.Athlete do
  use Ecto.Schema
  import Ecto.Changeset

  alias StravaData.Athletes.Activity
  alias StravaData.Athletes.Gear
  alias StravaData.Auth.AccessToken
  alias StravaData.Auth.RefreshToken

  @type t :: %__MODULE__{
          strava_id: :integer,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          username: String.t() | nil,
          profile_picture: String.t() | nil,
          activities: [Activity] | nil,
          gear: [Gear] | nil,
          access_token: AccessToken | nil,
          refresh_token: RefreshToken | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "athletes" do
    field :strava_id, :integer
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :profile_picture, :string

    has_many :activities, Activity, on_replace: :delete_if_exists
    has_many :gear, Gear, on_replace: :delete_if_exists

    has_one :access_token, AccessToken, on_replace: :update
    has_one :refresh_token, RefreshToken, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(athlete, attrs) do
    athlete
    |> cast(attrs, [:strava_id, :first_name, :last_name, :username, :profile_picture])
    |> unique_constraint(:strava_id)
    |> cast_assoc(:access_token, required: false)
    |> cast_assoc(:refresh_token, required: false)
    |> validate_required([:strava_id])
  end

  def gear_changeset(athlete, gear_attrs) do
    athlete
    |> change()
    |> put_assoc(:gear, gear_attrs)
  end

  def activities_changeset(athlete, activities_attrs) do
    athlete
    |> change()
    |> put_assoc(:activities, activities_attrs)
  end
end
