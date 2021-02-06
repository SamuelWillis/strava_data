defmodule StravaData.Api.Client do
  alias StravaData.Auth
  alias StravaData.Api.OAuthStrategy

  defdelegate authorize_url!, to: OAuthStrategy

  @spec get_token!(code: String.t()) :: OAuth2.AccessToken.t()
  def get_token!(code: code) do
    client = OAuthStrategy.get_token!(code: code)

    client.token
  end

  def get_authenticated_athlete!(athlete) do
    athlete
    |> build_client()
    |> OAuthStrategy.get!("/athlete", [], [])
    |> Map.get(:body, [])
  end

  def get_activities_page!(athlete, opts) do
    page = Keyword.get(opts, :page, 1)

    client_opts = [params: %{page: page, per_page: 50}]

    athlete
    |> build_client()
    |> OAuthStrategy.get!("/athlete/activities", [], client_opts)
    |> Map.get(:body, [])
  end

  def build_client(athlete) do
    access_token = Auth.get_access_token_for(athlete)

    refresh_token = Auth.get_refresh_token_for(athlete)

    expires_in =
      access_token.expires_at
      |> DateTime.diff(DateTime.utc_now())

    token =
      OAuth2.AccessToken.new(%{
        "access_token" => access_token.token,
        "expires_in" => expires_in,
        "refresh_token" => refresh_token.token
      })

    client = OAuthStrategy.client(token: token)

    case OAuth2.AccessToken.expired?(token) do
      true -> refresh_tokens!(client, athlete)
      _ -> client
    end
  end

  defp refresh_tokens!(client, athlete) do
    client = OAuthStrategy.refresh_tokens!(client)
    Auth.update_athlete_tokens!(athlete, client.token)
    client
  end
end
