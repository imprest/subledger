defmodule SubledgerWeb.LedgerHandler do
  use ChannelHandler

  def get(%{"id" => _id}, _bindings, socket) do
    ledger = Subledger.Setup.get_ledger("1_2023-24_CASH")
    {:reply, {:ok, %{data: "ledger data #{ledger.op_bal}"}}, socket}
  end

end
