defmodule Subledger.Public.Currency do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "currencies" do
    field :name, :string
    field :symbol, :string
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:id, :name, :symbol])
    |> validate_required([:id, :name, :symbol])
  end
end
