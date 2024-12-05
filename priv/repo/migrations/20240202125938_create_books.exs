defmodule Subledger.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :fin_year, :integer, null: false
      add :period, :daterange, null: false
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :currency_id, references(:currencies, on_delete: :nothing, type: :string), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:books, [:id, :org_id])
    create unique_index(:books, [:org_id, :fin_year])
  end
end
