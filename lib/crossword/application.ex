defmodule Crossword.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CrosswordWeb.Telemetry,
      Crossword.Repo,
      {DNSCluster, query: Application.get_env(:crossword, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Crossword.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Crossword.Finch},
      # Start a worker by calling: Crossword.Worker.start_link(arg)
      # {Crossword.Worker, arg},
      # Start to serve requests, typically the last entry
      CrosswordWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crossword.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrosswordWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
