defmodule Subledger.Books.Book do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias PgRanges.DateRange
  alias Subledger.Books.BookLedger
  alias Subledger.Ledgers.Ledger
  alias Subledger.Users.User

  schema "books" do
    belongs_to :org, Subledger.Orgs.Org
    belongs_to :currency, Subledger.Public.Currency, type: :string
    field :fin_year, :integer
    field :period, DateRange
    belongs_to :inserted_by, User
    belongs_to :updated_by, User
    many_to_many :ledgers, Ledger, join_through: BookLedger

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:fin_year, :period, :org_id, :currency_id, :inserted_by_id, :updated_by_id])
    |> validate_required([
      :fin_year,
      :period,
      :org_id,
      :currency_id,
      :inserted_by_id,
      :updated_by_id
    ])
  end
end
