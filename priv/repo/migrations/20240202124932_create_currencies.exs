defmodule Subledger.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :text, primary_key: true
      add :name, :string
      add :symbol, :text
    end
  end
end
