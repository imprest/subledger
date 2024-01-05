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

alias Subledger.Accounts
alias Subledger.Public
alias Subledger.Repo
alias Subledger.Setup

inserted_at = ~U[2023-10-01 08:00:00Z]
updated_at = ~U[2023-10-01 08:00:00Z]

Repo.insert!(%Public.Country{id: "GHA", name: "Ghana"}, skip_org_id: true)

Repo.insert_all(
  Public.Currency,
  [
    %{id: "GHS", name: "Ghana Cedis", symbol: "Ghc"},
    %{id: "USD", name: "U.S. Dollar", symbol: "$"},
    %{id: "EUR", name: "Euro", symbol: "€"},
    %{id: "GBP", name: "Great British Pound", symbol: "£"}
  ],
  skip_org_id: true
)

org =
  Repo.insert!(
    %Setup.Org{
      org_id: 1,
      sname: "MGP",
      name: "M&G Pharmaceuticals Ltd",
      inserted_at: inserted_at,
      updated_at: updated_at
    },
    skip_org_id: true
  )

org_id = org.org_id
Subledger.Repo.put_org_id(org_id)

{:ok, u} =
  Accounts.register_user(%{
    org_id: org_id,
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
    id: "1_2022",
    org_id: org_id,
    fin_year: 2022,
    currency_id: "GHS",
    period: [~D[2022-10-01], ~D[2023-10-01]],
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    id: "1_2023",
    org_id: org_id,
    fin_year: 2023,
    currency_id: "GHS",
    period: [~D[2023-10-01], ~D[2024-10-01]],
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  }
])

Repo.insert!(%Setup.Ledger{
  id: "1_2023_CASH",
  org_id: org_id,
  book_id: "1_2023",
  code: "CASH",
  name: "Cash",
  currency_id: "GHS",
  address_1: "Bannerman Road, James Town",
  address_2: "P.O. Box 1681",
  town_city: "Accra",
  region: "GAR",
  is_gov: false,
  tin: "C0000000000",
  country_id: "GHA",
  price_level: "Cash",
  credit_limit: 0.00,
  payment_terms: "Cash or Immediate Chq",
  tags: ["CASH"],
  inserted_by_id: user_id,
  updated_by_id: user_id,
  inserted_at: inserted_at,
  updated_at: updated_at
})

Repo.insert!(%Setup.Permission{
  org_id: org_id,
  ledger_id: "1_2023_CASH",
  user_id: user_id,
  role: :owner,
  inserted_by_id: user_id,
  updated_by_id: user_id,
  inserted_at: inserted_at,
  updated_at: updated_at
})
