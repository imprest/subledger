defmodule Subledger.Setup.Tx do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @required [:ledger_id, :date, :type, :narration, :amount, :inserted_by_id, :updated_by_id]
  @fields @required ++ [:note, :verified_at, :verified_by, :cell_colour, :text_colour]
  @types [
    "invoice",
    "rtn chq",
    "write-off",
    "discount",
    "cash",
    "chq",
    "momo",
    "tcc"
  ]

  @primary_key {:id, :string, autogenerate: false}
  schema "tx" do
    belongs_to :org, Subledger.Setup.Org, references: :org_id
    belongs_to :book, Subledger.Setup.Book, type: :binary
    belongs_to :ledger, Subledger.Setup.Ledger, type: :binary
    field :date, :date
    field :type, :string, default: "invoice"
    field :narration, :string
    field :amount, :decimal, default: 0.00
    field :text_colour, :string, default: "#000"
    field :cell_colour, :string, default: "#fff"
    field :is_deleted, :boolean, default: false
    field :note, :string
    field :ref_id, :string
    belongs_to :inserted_by, Subledger.Accounts.User
    belongs_to :updated_by, Subledger.Accounts.User
    belongs_to :verified_by, Subledger.Accounts.User
    field :verified_at, :date
    timestamps()
  end

  @doc false
  def changeset(tx, attrs) do
    tx
    |> cast(attrs, @fields)
    |> validate_required(@required)
    |> validate_tx_types(@types)
  end

  defp validate_tx_types(tx, types) do
    Enum.any?(tx, types)
  end
end
