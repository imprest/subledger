defmodule Subledger.Setup.Book do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "books" do
    belongs_to :org, Subledger.Setup.Org, references: :org_id
    belongs_to :currency, Subledger.Public.Currency, type: :string
    field :fin_year, :integer
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
