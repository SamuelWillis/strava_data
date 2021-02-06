defmodule StravaData.Athletes do
  import Ecto.Query, only: [from: 2]

  alias StravaData.Api
  alias StravaData.Athletes.Activity
  alias StravaData.Athletes.Athlete
  alias StravaData.Athletes.AthleteSupervisor
  alias StravaData.Repo

  @doc """
  Get an athlete
  """
  def get_athlete(id) do
    Athlete
    |> Repo.get(id)
    |> preload_tokens()
  end

  @doc """
  Get the activities for an athlete, sorted by date
  """
  def get_activities_for(%Athlete{id: athlete_id}) do
    Repo.all(
      from a in Activity, where: a.athlete_id == ^athlete_id, order_by: [desc: a.start_date_local]
    )
  end

  @doc """
  Update an athlete's data
  """
  @spec update_athlete(Athlete.t(), map()) :: {:ok, Athlete.t()} | {:error, Ecto.Changeset.t()}
  def update_athlete(%Athlete{} = athlete, attrs) do
    athlete
    |> Athlete.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update the gear for an athlete
  """
  @spec update_athlete_gear(Athlete.t(), list()) ::
          {:ok, Athlete.t()} | {:error, Ecto.Changeset.t()}
  def update_athlete_gear(athlete, gear_attrs) do
    athlete
    |> Repo.preload([:gear])
    |> Athlete.gear_changeset(gear_attrs)
    |> Repo.update()
  end

  @spec update_athlete_activities(Athlete.t(), list()) ::
          {:ok, Athlete.t()} | {:error, Ecto.Changeset.t()}
  def update_athlete_activities(athlete, activities_attrs) do
    athlete
    |> Repo.preload([:activities])
    |> Athlete.activities_changeset(activities_attrs)
    |> Repo.update()
  end

  @doc """
  Gather the athlete's data from strava
  """
  def start_gather_athlete_data(%Athlete{} = athlete) do
    AthleteSupervisor.gather_athlete_data(athlete)
  end

  @doc """
  Initializes an athlete based on the data returned by the Strava OAuth service
  """
  @spec initialize_athlete!(code: String.t()) :: Athlete.t()
  def initialize_athlete!(code: code) do
    oauth_token = Api.get_token!(code: code)
    attrs = cast_attrs_from_oauth_token(oauth_token)

    insert_or_update_athlete!(attrs)
  end

  defp cast_attrs_from_oauth_token(%OAuth2.AccessToken{} = token) do
    %{}
    |> athlete_attrs_from_oauth_token(token)
    |> Map.put(:access_token, %{
      token: token.access_token,
      expires_at: token.expires_at |> DateTime.from_unix!() |> DateTime.to_naive(),
      token_type: token.token_type
    })
    |> Map.put(:refresh_token, %{
      token: token.refresh_token
    })
  end

  @doc """
  Insert or update an athlete based on the attrs provided
  """
  def insert_or_update_athlete!(%{strava_id: strava_id} = attrs) do
    Repo.get_by(Athlete, strava_id: strava_id)
    |> case do
      %Athlete{} = athlete -> preload_tokens(athlete)
      nil -> %Athlete{}
    end
    |> Athlete.changeset(attrs)
    |> Repo.insert_or_update!()
  end

  defp athlete_attrs_from_oauth_token(attrs, %OAuth2.AccessToken{other_params: other_params}) do
    athlete = Map.get(other_params, "athlete", %{})

    Map.merge(attrs, %{
      strava_id: athlete["id"],
      first_name: athlete["firstname"],
      last_name: athlete["lastname"],
      username: athlete["username"],
      profile_picture: athlete["profile_medium"]
    })
  end

  defp preload_tokens(athlete), do: Repo.preload(athlete, [:access_token, :refresh_token])
end
