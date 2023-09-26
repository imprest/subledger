defmodule SubledgerWeb.SvelteHTML do
  use SubledgerWeb, :html

  def index(assigns) do
    ~H"""
    <%= if System.get_env("PHX_SERVER", "false") == "false" do %>
      <script type="module" src="http://localhost:5173/@vite/client">
      </script>
      <script type="module" src="http://localhost:5173/src/main.ts">
      </script>
    <% else %>
      <script defer phx-track-static type="text/javascript" src={~p"/assets/main.js"}>
      </script>
    <% end %>
    <noscript>You need to enable Javascript to run this app.</noscript>
    <div id="app"></div>
    """
  end
end
