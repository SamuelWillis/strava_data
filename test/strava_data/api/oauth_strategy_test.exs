defmodule StravaData.Api.OAuthStrategyTest do
  use StravaData.DataCase, async: true

  alias StravaData.Api.OAuthStrategy

  describe "authorize_url!/0" do
    test "returns expected url" do
      client_id = System.get_env("STRAVA_CLIENT_ID")
      redirect_uri = URI.encode_www_form("http://localhost:4000/api/auth/callback")
      response_type = URI.encode_www_form("code")
      scope = URI.encode_www_form("read,activity:read,profile:read_all")

      assert "https://www.strava.com/oauth/authorize?approval_prompt=force&client_id=#{client_id}&redirect_uri=#{
               redirect_uri
             }&response_type=#{response_type}&scope=#{scope}" ==
               OAuthStrategy.authorize_url!()
    end
  end
end
