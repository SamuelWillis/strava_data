defmodule StravaData.Repo.Migrations.CreateAccessTokens do
  use Ecto.Migration

  def change do
    create table(:access_tokens) do
      add(:token, :string)
      add(:expires_at, :naive_datetime)
      add(:token_type, :string)

      add(:athlete_id, references(:athletes, type: :uuid, validate: true, on_delete: :delete_all))

      timestamps()
    end
  end
end
