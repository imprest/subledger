defmodule Subledger.Setup.Book do
  use Subledger.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "books" do
    belongs_to :org, Subledger.Setup.Org
    belongs_to :currency, Subledger.Public.Currency, type: :string
    field :fin_year, :string
    field :period, Subledger.DateRange
    belongs_to :inserted_by, Subledger.Accounts.User
    belongs_to :updated_by, Subledger.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:org, :fin_year, :period, :currency])
    |> validate_required([:org, :fin_year, :period, :currency])
  end
end
