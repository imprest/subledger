defmodule Subledger.Public.Country do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string
  schema "countries" do
    field :name, :string
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
