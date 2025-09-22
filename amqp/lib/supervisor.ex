defmodule Libremarket.Supervisor do
  use Supervisor

  @doc """
  Inicia el supervisor
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp load_config() do
    case File.read("config.json") do
      {:ok, contents} -> parse_json_config(contents)
      {:error, _} -> load_default_config()
    end
  end

  defp parse_json_config(contents) do
    case Jason.decode(contents) do
      {:ok, json} -> parse_servers(json["servers"])
      {:error, _} -> load_default_config()
    end
  end

  defp parse_servers(servers) when is_list(servers) do
    Enum.map(servers, fn server ->
      {String.to_existing_atom("Elixir." <> server["type"]), %{}}
    end)
  end

  defp load_default_config() do
    case System.get_env("SERVER_TO_RUN") do
      nil -> []
      server_to_run -> [ {String.to_existing_atom("Elixir." <> server_to_run <> ".Server"), %{}} ]
    end
  end

  @impl true
  def init(_opts) do
    topologies = [
      gossip: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "127.0.0.1",
          broadcast_only: true,
          secret: "secret"
        ]
      ]
    ]
    childrens = [
      {Cluster.Supervisor, [topologies, [name: Libremarket.ClusterSupervisor]]},
      {Compras.AMQP, []}
    ] ++ load_config()
    Supervisor.init(childrens, strategy: :one_for_one)
  end
end
