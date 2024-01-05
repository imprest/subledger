defmodule Subledger.Setup.Permission do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @required [:ledger_id, :user_id, :org_id, :inserted_by_id, :updated_by_id, :role]
  @fields @required

  @primary_key false
  schema "permissions" do
    belongs_to :org, Subledger.Setup.Org, references: :org_id, primary_key: true
    belongs_to :ledger, Subledger.Setup.Ledger, type: :binary, primary_key: true
    belongs_to :user, Subledger.Accounts.User, primary_key: true
    field :role, Ecto.Enum, values: [:owner, :editor, :viewer], default: :viewer
    belongs_to :inserted_by, Subledger.Accounts.User
    belongs_to :updated_by, Subledger.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
