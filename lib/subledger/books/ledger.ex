defmodule Subledger.Books.Ledger do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Subledger.Books.Book
  alias Subledger.Books.BookLedger

  schema "ledgers" do
    field :code, :string
    field :name, :string
    field :number, :string
    field :is_active, :boolean, default: false
    field :tin, :string
    field :town_city, :string
    field :region, :string
    field :is_gov, :boolean, default: false
    field :address_1, :string
    field :address_2, :string
    field :email, :string
    field :price_level, :string, default: "Trek"
    field :credit_limit, :decimal, default: 0.00
    field :payment_terms, :string, default: "Cash or Immediate Chq"
    field :tags, {:array, :string}
    belongs_to :org, Subledger.Orgs.Org
    belongs_to :country, Subledger.Global.Country, type: :string
    belongs_to :inserted_by, Subledger.Users.User
    belongs_to :updated_by, Subledger.Users.User
    belongs_to :currency, Subledger.Global.Currency, type: :string
    many_to_many :books, Book, join_through: BookLedger

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [
      :code,
      :is_active,
      :tin,
      :town_city,
      :region,
      :is_gov,
      :number,
      :address_1,
      :address_2,
      :email,
      :price_level,
      :credit_limit,
      :payment_terms,
      :tags
    ])
    |> validate_required([
      :code,
      :is_active,
      :tin,
      :town_city,
      :region,
      :is_gov,
      :number,
      :address_1,
      :address_2,
      :email,
      :price_level,
      :credit_limit,
      :payment_terms,
      :tags
    ])
  end
end
