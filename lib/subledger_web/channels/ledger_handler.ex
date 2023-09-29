defmodule SubledgerWeb.LedgerHandler do
  use ChannelHandler

  alias Subledger.Setup

  def get(%{"id" => _id}, _bindings, socket) do
    ledger = Setup.get_ledger("1_2023_CASH")
    {:reply, {:ok, %{data: "#{ledger.book_id} ledger #{ledger.name}"}}, socket}
  end
end
