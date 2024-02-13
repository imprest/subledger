defmodule Subledger.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add :org_id, :bigint, null: false, primary_key: true

      add :user_id,
          references(:users, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          primary_key: true

      add :ledger_id,
          references(:ledgers, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          primary_key: true

      add :role, :string, default: "viewer", null: false

      add :inserted_by_id,
          references(:users, with: [org_id: :org_id], match: :full, on_delete: :nothing)

      add :updated_by_id,
          references(:users, with: [org_id: :org_id], match: :full, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:org_id, :ledger_id, :user_id])
    create index(:permissions, [:org_id])
    create index(:permissions, [:ledger_id])
    create index(:permissions, [:user_id])
    create index(:permissions, [:inserted_by_id])
    create index(:permissions, [:updated_by_id])
  end
end
