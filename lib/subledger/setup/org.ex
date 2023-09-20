defmodule Subledger.Setup.Org do
  use Subledger.Schema
  import Ecto.Changeset

  schema "orgs" do
    field :name, :string
    field :sname, :string
    timestamps()
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :sname])
    |> validate_required([:name, :sname])
  end

  @doc false
  def create_new(org, attrs) do
    changeset(org, attrs)
  end
end
