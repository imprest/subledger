defmodule Subledger.Setup.Ledger do
  @moduledoc false
  use Subledger.Schema

  import Ecto.Changeset

  @required [:is_active, :code, :name, :op_bal, :book_id]
  @fields @required

  @primary_key {:id, :string, autogenerate: false}
  schema "ledgers" do
    field :is_active, :boolean, default: true
    field :code, :string
    field :name, :string
    field :is_gov, :boolean, default: false
    field :op_bal, :decimal, default: 0.00
    belongs_to :org, Subledger.Setup.Org, references: :org_id
    field :tin, :string
    field :town_city, :string
    belongs_to :country, Subledger.Public.Country, type: :binary
    field :region, :string
    field :number, :string
    field :address_1, :string
    field :address_2, :string
    field :email, :string
    field :price_level, :string, default: "Trek"
    field :credit_limit, :decimal, default: 0.00
    field :payment_terms, :string, default: "Cash or Immediate Chq"
    field :tags, {:array, :string}
    belongs_to :book, Subledger.Setup.Book, type: :binary
    belongs_to :currency, Subledger.Public.Currency, type: :binary
    belongs_to :inserted_by, Subledger.Accounts.User
    belongs_to :updated_by, Subledger.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
