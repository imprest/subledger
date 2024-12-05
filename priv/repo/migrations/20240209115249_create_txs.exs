defmodule Subledger.Repo.Migrations.CreateTxs do
  use Ecto.Migration

  def change do
    create table(:txs, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :book_id,
          references(:books, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false

      add :ledger_id,
          references(:ledgers, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false

      add :org_id, :bigint, null: false
      add :date, :date, default: fragment("now()"), null: false
      add :type, :string, null: false
      add :narration, :string, null: false
      add :amount, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      add :is_deleted, :boolean, default: false, null: false
      add :is_paid, :boolean, default: false, null: false
      add :ref_id, :string
      add :note, :string
      add :pvt_note, :string

      add :inserted_by_id,
          references(:users, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false

      add :updated_by_id,
          references(:users, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false

      timestamps(type: :utc_datetime)
    end
  end
end
