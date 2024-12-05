defmodule Subledger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SubledgerWeb.Telemetry,
      Subledger.Repo,
      {DNSCluster, query: Application.get_env(:subledger, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Subledger.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Subledger.Finch},
      # Start Presence
      SubledgerWeb.Presence,
      # Start to serve requests, typically the last entry
      SubledgerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Subledger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SubledgerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
