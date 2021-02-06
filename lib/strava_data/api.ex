defmodule StravaData.Api do
  alias StravaData.Api.Client

  defdelegate authorize_url!, to: Client

  defdelegate get_token!(opts), to: Client

  defdelegate get_authenticated_athlete!(athlete), to: Client

  defdelegate get_activities_page!(athlete, opts), to: Client
end
