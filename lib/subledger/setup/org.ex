defmodule Subledger.Setup.Org do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @primary_key {:org_id, :id, autogenerate: true}
  schema "orgs" do
    field :name
    field :sname
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
