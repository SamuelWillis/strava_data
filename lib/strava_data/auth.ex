defmodule StravaData.Auth do
  import Ecto.Query, only: [from: 2]

  alias OAuth2.AccessToken, as: OAuth2AccessToken
  alias StravaData.Api.OAuthStrategy
  alias StravaData.Athletes.Athlete
  alias StravaData.Auth.AccessToken
  alias StravaData.Auth.RefreshToken
  alias StravaData.Repo

  defdelegate authorize_url!, to: OAuthStrategy

  @doc """
  Get the access token for an athlete
  """
  @spec get_access_token_for(Athlete.t()) :: AccessToken.t()
  def get_access_token_for(%Athlete{id: id}),
    do: Repo.one(from t in AccessToken, where: t.athlete_id == ^id)

  @doc """
  Get the refresh token for an athlete
  """
  @spec get_refresh_token_for(Athlete.t()) :: RefreshToken.t()
  def get_refresh_token_for(%Athlete{id: id}),
    do: Repo.one(from t in RefreshToken, where: t.athlete_id == ^id)

  @doc """
  Update athlete tokens.

  Accepts an OAuth2.AccessToken struct or a map of attrs for update values
  """
  @spec update_athlete_tokens!(Athlete.t(), OAuth2AccessToken.t() | map()) ::
          {:ok, Athlete.t()} | {:error, Ecto.Changeset.t()}
  def update_athlete_tokens!(%Athlete{} = athlete, %OAuth2AccessToken{} = client_token) do
    token_attrs =
      %{
        athlete_id: athlete.id,
        strava_id: athlete.strava_id
      }
      |> access_token_attrs(client_token)
      |> refresh_token_attrs(client_token)

    update_athlete_tokens!(athlete, token_attrs)
  end

  def update_athlete_tokens!(%Athlete{} = athlete, token_attrs) do
    athlete
    |> Athlete.changeset(token_attrs)
    |> Repo.insert_or_update!()
  end

  defp access_token_attrs(attrs, %OAuth2AccessToken{} = token),
    do:
      Map.put(attrs, :access_token, %{
        token: token.access_token,
        expires_at: token.expires_at |> DateTime.from_unix!() |> DateTime.to_naive(),
        token_type: token.token_type
      })

  defp refresh_token_attrs(attrs, %OAuth2AccessToken{} = token),
    do:
      Map.put(attrs, :refresh_token, %{
        token: token.refresh_token
      })
end
