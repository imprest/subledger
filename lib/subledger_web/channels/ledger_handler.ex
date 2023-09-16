defmodule SubledgerWeb.LedgerHandler do
  use ChannelHandler

  def get(%{"id" => id}, bindings, socket) do
    IO.inspect(bindings)
    {:reply, {:ok, %{data: "ledger data #{id}"}}, socket}
  end

end
