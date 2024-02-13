defmodule Subledger.Orgs.Org do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "orgs" do
    field :name, :string
    field :sname, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:sname, :name])
    |> validate_required([:sname, :name])
  end
end
