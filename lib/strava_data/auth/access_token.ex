defmodule StravaData.Auth.AccessToken do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          token: String.t(),
          token_type: String.t(),
          expires_at: DateTime.t(),
          athlete: StravaData.Athletes.Athlete.t()
        }

  schema "access_tokens" do
    field :expires_at, :utc_datetime
    field :token, :string
    field :token_type, :string
    belongs_to :athlete, StravaData.Athletes.Athlete, type: :binary_id, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(access_token, attrs) do
    access_token
    |> cast(attrs, [:athlete_id, :token, :expires_at, :token_type])
    |> validate_required([:token, :expires_at, :token_type])
  end
end
