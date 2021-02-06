defmodule StravaData.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add(:token, :string)

      add(:athlete_id, references(:athletes, type: :uuid, validate: true, on_delete: :delete_all))

      timestamps()
    end
  end
end
