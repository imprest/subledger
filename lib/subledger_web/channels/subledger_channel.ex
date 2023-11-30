defmodule SubledgerWeb.SubledgerChannel do
  use SubledgerWeb, :channel

  alias SubledgerWeb.Presence
  alias Subledger.Setup

  @impl true
  def join("subledger:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("subledger:" <> user_id, _payload, socket) do
    # if authorized?(payload) do
    if socket.assigns.user_id === String.to_integer(user_id) do
      Subledger.Repo.put_org_id(socket.assigns.org_id)
      socket = assign(socket, :books, Setup.get_books_list(socket.assigns.org_id))
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
    {:reply, Setup.get_books(socket.assigns.org_id), socket}
  end

  @impl true
  def handle_in("ledgers:get", %{"book_id" => book_id}, socket) do
    case book_id do
      "" ->
        book_id = hd(socket.assigns.books)
        {:reply, Setup.list_ledgers(socket.assigns.user_id, book_id), socket}

      _ ->
        {:reply, Setup.list_ledgers(socket.assigns.user_id, book_id), socket}
    end
  end

  @impl true
  def handle_in("ledgers:get", _payload, socket) do
    book_id = hd(socket.assigns.books)
    {:reply, Setup.list_ledgers(socket.assigns.user_id, book_id), socket}
  end

  @impl true
  def handle_in("ledger:get", %{"id" => id}, socket) do
    {:reply, Setup.get_ledger(id), socket}
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
end
