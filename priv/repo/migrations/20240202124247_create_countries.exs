defmodule Subledger.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :string
    end

    create unique_index(:countries, [:name])
  end
end
