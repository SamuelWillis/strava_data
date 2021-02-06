defmodule StravaData.Auth.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          token: String.t(),
          athlete: StravaData.Athletes.Athlete.t()
        }

  schema "refresh_tokens" do
    field :token, :string
    belongs_to :athlete, StravaData.Athletes.Athlete, type: :binary_id, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:athlete_id, :token])
    |> validate_required([:token])
  end
end
