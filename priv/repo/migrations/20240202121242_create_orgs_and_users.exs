defmodule Subledger.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:orgs, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :sname, :text, null: false
      add :name, :text, null: false

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
      add :confirmed_at, :naive_datetime
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
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
