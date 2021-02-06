defmodule StravaData.AuthTest do
  use StravaData.DataCase, async: true

  alias StravaData.Auth
  alias StravaData.Auth.AccessToken
  alias StravaData.Auth.RefreshToken

  describe "get_access_token_for/1" do
    test "returns nil when no token" do
      athlete = insert(:athlete)

      assert nil == Auth.get_access_token_for(athlete)
    end

    test "returns access token" do
      %{id: athlete_id} = athlete = insert(:athlete_with_tokens)

      assert %AccessToken{athlete_id: ^athlete_id} = Auth.get_access_token_for(athlete)
    end
  end

  describe "get_refresh_token_for/1" do
    test "returns nil when no token" do
      athlete = insert(:athlete)

      assert nil == Auth.get_refresh_token_for(athlete)
    end

    test "returns refresh token" do
      %{id: athlete_id} = athlete = insert(:athlete_with_tokens)

      assert %RefreshToken{athlete_id: ^athlete_id} = Auth.get_refresh_token_for(athlete)
    end
  end

  describe "update_athlete_tokens!/2" do
    test "updates athlete tokens" do
      athlete = insert(:athlete_with_tokens)
      now = DateTime.truncate(DateTime.utc_now(), :second)

      attrs = %{
        refresh_token: %{
          token: "new_refresh_token"
        },
        access_token: %{
          token: "new_access_token",
          expires_at: now,
          token_type: "Bearer"
        }
      }

      athlete = Auth.update_athlete_tokens!(athlete, attrs)

      assert %StravaData.Auth.AccessToken{
               token: "new_access_token",
               expires_at: ^now,
               token_type: "Bearer"
             } = athlete.access_token

      assert %StravaData.Auth.RefreshToken{
               token: "new_refresh_token"
             } = athlete.refresh_token
    end
  end
end
