defmodule Subledger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SubledgerWeb.Telemetry,
      # Start the Ecto repository
      Subledger.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Subledger.PubSub},
      # Start Finch
      {Finch, name: Subledger.Finch},
      # Start the Endpoint (http/https)
      SubledgerWeb.Endpoint
      # Start a worker by calling: Subledger.Worker.start_link(arg)
      # {Subledger.Worker, arg}
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
