defmodule Subledger.Public.Country do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "countries" do
    field :name, :string
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:country])
    |> validate_required([:country])
  end
end
