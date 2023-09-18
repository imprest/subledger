defmodule Subledger.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""
    execute "CREATE EXTENSION IF NOT EXISTS pg_stat_statements", ""

    create table(:orgs) do
      add :sname, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:orgs, [:sname])

    create table(:countries, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :text, null: false
    end

    create table(:currencies, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :text, null: false
      add :symbol, :text, null: false
    end

    create table(:users) do
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :username, :string, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :is_admin, :boolean, null: false, default: false
      add :name, :string, null: false
      add :confirmed_at, :utc_datetime
      timestamps()
    end

    create unique_index(:users, [:username])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

  end
end
