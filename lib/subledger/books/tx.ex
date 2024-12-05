defmodule Subledger.Books.Tx do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Subledger.Accounts.Org
  alias Subledger.Accounts.User
  alias Subledger.Books.Book
  alias Subledger.Books.Ledger

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  schema "txs" do
    field :type, Ecto.Enum,
      values: [
        :invoice,
        :refund,
        :chq,
        :cash,
        :momo,
        :rtn_chq,
        :write_off,
        :discount,
        :tcc,
        :debit,
        :credit,
        :transfer
      ]

    field :date, :date
    field :narration, :string
    field :amount, :decimal, default: 0.0
    field :is_deleted, :boolean, default: false
    field :is_paid, :boolean, default: false
    field :note, :string
    field :pvt_note, :string
    field :ref_id, :string
    belongs_to :org, Org
    belongs_to :book, Book
    belongs_to :ledger, Ledger
    belongs_to :inserted_by, User
    belongs_to :updated_by, User

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(tx, attrs) do
    tx
    |> cast(attrs, [
      :date,
      :type,
      :narration,
      :amount,
      :is_deleted,
      :is_paid,
      :note,
      :pvt_note,
      :ref_id,
      :book_id,
      :ledger_id,
      :org_id,
      :inserted_by_id,
      :updated_by_id
    ])
    |> validate_required([
      :date,
      :type,
      :narration,
      :amount,
      :book_id,
      :ledger_id,
      :org_id,
      :inserted_by_id,
      :updated_by_id
    ])
  end
end
