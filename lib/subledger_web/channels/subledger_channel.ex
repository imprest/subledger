defmodule SubledgerWeb.SubledgerChannel do
  @moduledoc "Main interface for client api"
  use SubledgerWeb, :channel

  alias Subledger.Books
  alias Subledger.Ledgers
  alias SubledgerWeb.Presence

  @impl true
  def join("subledger:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("subledger:" <> user_id, _payload, socket) do
    # if authorized?(payload) do
    if socket.assigns.user_id === String.to_integer(user_id) do
      socket = assign(socket, :books, Books.list_books(socket.assigns.org_id))
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (subledger:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("books:get", _payload, socket) do
    {:reply, Books.get_books(socket.assigns.org_id), socket}
  end

  @impl true
  def handle_in("ledgers:get", %{"fin_year" => fin_year}, socket) do
    book_id = fin_year_to_book_id(socket.assigns.books, fin_year)
    {:reply, Ledgers.list_ledgers(socket.assigns.user_id, book_id), socket}
  end

  @impl true
  def handle_in("ledgers:get", _payload, socket) do
    book_id = hd(socket.assigns.books)
    {:reply, Ledgers.list_ledgers(socket.assigns.user_id, book_id), socket}
  end

  @impl true
  def handle_in("ledger:get", %{"code" => code, "fin_year" => fin_year}, socket) do
    book_id = fin_year_to_book_id(socket.assigns.books, fin_year)
    {:reply, Ledgers.get_ledger(code, book_id), socket}
  end

  @impl true
  def handle_in("ledger:add_txs", %{"txs" => txs, "ledger_id" => ledger_id}, socket) do
    IO.inspect(ledger_id)
    IO.inspect(txs)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    # presence = Presence.get_by_key(socket, socket.assigns.name)
    # IO.inspect(presence, label: "Presence Data:")

    {:ok, _} =
      Presence.track(socket, socket.assigns.name, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  defp fin_year_to_book_id(books, 0), do: Map.get(hd(books), :id)

  defp fin_year_to_book_id(books, fin_year), do: books |> Enum.find(fn x -> x.fin_year == fin_year end) |> Map.get(:id)
end
