defmodule Subledger.Repo.Migrations.CreateLedgers do
  use Ecto.Migration

  def change do
    create table(:ledgers) do
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :code, :text, null: false
      add :name, :text, null: false
      add :is_active, :boolean, default: true, null: false
      add :tin, :text, null: false, default: "C000000000"
      add :region, :string, null: false
      add :is_gov, :boolean, default: false, null: false
      add :number, :text, null: false, default: "0000000000"
      add :credit_limit, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      add :payment_terms, :text, default: "Cash or Immediate Chq"
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      add :currency_id, references(:currencies, on_delete: :nothing, type: :string), null: false
      add :country_id, references(:countries, on_delete: :nothing, type: :string), null: false
      add :address_1, :text
      add :address_2, :text
      add :town_city, :string, null: false
      add :email, :text
      add :price_level, :text, default: "Trek"
      add :tags, {:array, :string}
      timestamps(type: :utc_datetime)
    end

    create unique_index(:ledgers, [:id, :org_id])
    create unique_index(:ledgers, [:org_id, :code])

    create index(:ledgers, [:org_id])
    create index(:ledgers, [:country_id])
    create index(:ledgers, [:inserted_by_id])
    create index(:ledgers, [:updated_by_id])
    create index(:ledgers, [:currency_id])

    create table(:books_ledgers, primary_key: false) do
      add :org_id, :bigint, null: false, primary_key: true

      add :book_id,
          references(:books, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false,
          primary_key: true

      add :ledger_id,
          references(:ledgers, with: [org_id: :org_id], match: :full, on_delete: :nothing),
          null: false,
          primary_key: true

      add :op_bal, :decimal, default: 0.00, null: false, precision: 20, scale: 2
    end
  end
end
