defmodule Subledger.Users.Permission do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Subledger.Ledgers.Ledger
  alias Subledger.Users.User

  @required [:ledger_id, :user_id, :org_id, :inserted_by_id, :updated_by_id, :role]
  @fields @required

  @primary_key false
  schema "permissions" do
    field :role, Ecto.Enum, values: [:owner, :editor, :viewer], default: :viewer
    field :org_id, :integer, primary_key: true
    belongs_to :user, User, primary_key: true
    belongs_to :ledger, Ledger, primary_key: true
    belongs_to :inserted_by, User
    belongs_to :updated_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
