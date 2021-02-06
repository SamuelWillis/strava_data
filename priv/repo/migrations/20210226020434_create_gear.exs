defmodule StravaData.Repo.Migrations.CreateGear do
  use Ecto.Migration

  def change do
    create table(:gear, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:strava_id, :string, null: false)
      add(:primary, :boolean, default: false, null: false)
      add(:name, :string)

      add(
        :athlete_id,
        references(:athletes, type: :uuid, validate: true, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    create(unique_index(:gear, [:strava_id]))
  end
end
