defmodule Subledger.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books, primary_key: false) do
      add :id, :string, primary_key: true
      add :org_id, references(:orgs, column: :org_id), null: false
      add :currency_id, references(:currencies, type: :string), null: false
      add :fin_year, :integer, null: false
      add :period, :daterange, null: false
      add :inserted_by_id, references(:users), null: false
      add :updated_by_id, references(:users), null: false
      timestamps()
    end

    create unique_index(:books, [:id, :org_id])
    create unique_index(:books, [:org_id, :fin_year])
    create index(:books, [:org_id])

    create table(:ledgers, primary_key: false) do
      # book_id+code
      add :id, :text, primary_key: true
      add :org_id, :bigint, null: false

      add :book_id,
          references(:books, with: [org_id: :org_id], match: :full, type: :string),
          null: false

      add :is_active, :boolean, default: true, null: false
      add :op_bal, :decimal, default: 0, null: false, precision: 20, scale: 2
      add :currency_id, references(:currencies, type: :string), null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :tin, :string, null: false, default: "C000000000"
      add :town_city, :string, null: false
      add :region, :string, null: false
      add :country_id, references(:countries, type: :string), default: "GHA", null: false
      add :is_gov, :boolean, null: false, default: false
      add :number, :text, null: false, default: "000000000"
      add :address_1, :text
      add :address_2, :text
      add :email, :string
      add :price_level, :string, default: "Trek"
      add :credit_limit, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      add :payment_terms, :string, default: "Cash or Immediate Chq"
      add :tags, {:array, :string}
      add :inserted_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      add :updated_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      timestamps()
    end

    create unique_index(:ledgers, [:id, :org_id])
    create unique_index(:ledgers, [:book_id, :code])

    create table(:tx, primary_key: false) do
      # book_id + incrementing tx number (10 digits)
      add :id, :text, primary_key: true
      add :org_id, :bigint, null: false

      add :book_id, references(:books, with: [org_id: :org_id], match: :full, type: :string),
        null: false

      add :ledger_id, references(:ledgers, with: [org_id: :org_id], match: :full, type: :string),
        null: false

      add :date, :date, default: fragment("now()"), null: false
      # invoice, rtn chq, debit note, credit note, discount, cash, chq, momo
      add :type, :string, null: false
      add :narration, :string, null: false
      add :amount, :decimal, default: 0.00, null: false, precision: 20, scale: 2
      # hex colours
      add :text_colour, :string, null: false, default: "#000"
      # hex colours
      add :cell_colour, :string, null: false, default: "#fff"
      add :inserted_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      add :updated_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      add :is_deleted, :boolean, default: false, null: false
      add :verified_at, :date
      add :verified_by_id, references(:users, with: [org_id: :org_id])
      add :note, :text
      add :ref_id, :string
      timestamps()
    end

    create index(:tx, [:ledger_id])

    create table(:permissions, primary_key: false) do
      add :org_id, :bigint, null: false

      add :ledger_id, references(:ledgers, with: [org_id: :org_id], match: :full, type: :string),
        null: false

      add :user_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      add :inserted_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      add :updated_by_id, references(:users, with: [org_id: :org_id], match: :full), null: false
      # owner, viewer, editor
      add :role, :string, null: false, default: "viewer"
      timestamps()
    end

    create unique_index(:permissions, [:org_id, :ledger_id, :user_id])
    create index(:permissions, [:ledger_id])
    create index(:permissions, [:user_id])
  end
end
