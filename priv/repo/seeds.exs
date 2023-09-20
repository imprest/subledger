# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Subledger.Repo.insert!(%Subledger.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Subledger.{Repo, Accounts, Public, Setup}

inserted_at = ~U[2023-10-01 08:00:00Z]
updated_at = ~U[2023-10-01 08:00:00Z]

Repo.insert!(%Public.Country{id: "GHA", name: "Ghana"})
Repo.insert_all(
  Public.Currency,
  [
    %{id: "GHS", name: "Ghana Cedis", symbol: "Ghc"},
    %{id: "USD", name: "U.S. Dollar", symbol: "$"},
    %{id: "EUR", name: "Euro", symbol: "€"},
    %{id: "GBP", name: "Great British Pound", symbol: "£"}
  ]
)

Repo.insert_all(Setup.Org, [
  %{id: 1, sname: "MGP", name: "M&G Pharmaceuticals Ltd", inserted_at: inserted_at, updated_at: updated_at}
])

{:ok, u} =
  Accounts.register_user(%{
    org_id: 1,
    username: "hvaria",
    email: "hardikvaria@gmail.com",
    name: "Hardik Varia",
    password: "Testing12345",
    is_admin: true
  })
user_id = u.id

Repo.update!(Accounts.User.confirm_changeset(u))
Repo.insert_all(Setup.Book, [
  %{
    id: "1_2023-24",
    org_id: 1,
    fin_year: "2023-24",
    currency_id: "GHS",
    period: [~D[2023-10-01], ~D[2024-10-01]],
    inserted_by_id: 1,
    updated_by_id: 1,
    inserted_at: inserted_at,
    updated_at: updated_at
  }
])

Repo.insert!(%Setup.Ledger{
  id: "1_2023-24_CASH",
  org_id: 1,
  book_id: "1_2023-24",
  code: "CASH",
  name: "Cash",
  currency_id: "GHS",
  address: "Bannerman Road, James Town",
  town_city: "Accra",
  region: "GAR",
  is_gov: false,
  tin: "C0000000000",
  country_id: "GHA",
  price_level: "Cash",
  credit_limit: 0.00,
  payment_terms: "Cash or Immediate Chq",
  tags: ["CASH"],
  inserted_by_id: 1,
  updated_by_id: 1,
  inserted_at: inserted_at,
  updated_at: updated_at
})
