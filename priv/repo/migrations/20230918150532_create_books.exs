defmodule Subledger.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books, primary_key: false) do
      add :id, :string, primary_key: true
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :fin_year, :string, null: false
      add :period, :daterange, null: false
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      timestamps()
    end

    create unique_index(:books, [:org_id, :fin_year])
    create index(:books, [:org_id])

    create table(:ledgers, primary_key: false) do
      add :id, :text, primary_key: true # book_id+code
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :book_id, references(:books, on_delete: :nothing, type: :string), null: false
      add :is_active, :boolean, default: true, null: false
      add :op_bal, :decimal, default: 0, null: false, precision: 20, scale: 2
      add :currency_id, references(:currencies, on_delete: :nothing, type: :string), null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :tin, :string, null: false, default: "C000000000"
      add :address, :text, null: false
      add :country_id, references(:countries, on_delete: :nothing, type: :string), default: "GHA", null: false
      add :number, :text, null: false, default: "000000000"
      add :email, :string, null: true
      add :price_level, :string, default: "Trek"
      add :credit_level, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      add :payment_terms, :string, default: "Cash or Immediate Chq"
      add :tags, {:array, :string}
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      timestamps()
    end

    create unique_index(:ledgers, [:book_id, :code])

    create table(:tx, primary_key: false) do
      add :id, :text, primary_key: true # book_id + incrementing tx number
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :ledger_id, references(:ledgers, on_delete: :nothing, type: :string), null: false
      add :date, :date, default: fragment("now()"), null: false
      add :type, :string, null: false # invoice, rtn chq, debit note, credit note, discount, cash, chq, momo
      add :narration, :string, null: false
      add :amount, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      add :text_colour, :string, null: false, default: "#000" # hex colours
      add :cell_colour, :string, null: false, default: "#fff" # hex colours
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      add :is_deleted, :boolean, default: false, null: false
      add :verified_at, :date
      add :verified_by_id, references(:users, on_delete: :nothing)
      add :note, :text
      timestamps()
    end

    create index(:tx, [:ledger_id])

    create table(:permissions, primary_key: false) do
      add :org_id, :bigint, null: false
      add :ledger_id, references(:ledgers, on_delete: :nothing, type: :string), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :inserted_by_id, references(:users, on_delete: :nothing), null: false
      add :updated_by_id, references(:users, on_delete: :nothing), null: false
      add :role, :string, null: false, default: "viewer" # owner, viewer, editor
      timestamps()
    end

    create unique_index(:permissions, [:ledger_id, :user_id])
    create index(:permissions, [:ledger_id])
    create index(:permissions, [:user_id])
    create index(:permissions, [:inserted_by_id])
    create index(:permissions, [:updated_by_id])
  end
end
