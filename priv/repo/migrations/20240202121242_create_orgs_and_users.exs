defmodule Subledger.Repo.Migrations.CreateOrgsUsersGlobals do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:orgs) do
      add :sname, :string
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:orgs, [:sname])

    create table(:users) do
      add :org_id, references(:orgs, on_delete: :nothing), null: false
      add :username, :citext, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :is_admin, :boolean, null: false, default: false
      add :name, :string, null: false
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:id, :org_id])
    create unique_index(:users, [:username])
    create unique_index(:users, [:org_id, :username])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    # Global tables
    create table(:countries, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :string
    end

    create unique_index(:countries, [:name])

    create table(:currencies, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :string
      add :symbol, :text
    end
  end
end
