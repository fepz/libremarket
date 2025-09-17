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

  # Si no se puede leer el archivo de configuración, se cargan los servidores por defecto
  defp load_default_config() do
    case System.get_env("SERVER_TO_RUN") do
      nil -> 
        [
          {Compras.Server, %{}},
          {Envios.Server, %{}},
          {Infracciones.Server, %{}},
          {Pagos.Server, %{}},
          {Ventas.Server, %{}}
        ]
      server_to_run -> [{String.to_existing_atom("Elixir." <> server_to_run), %{}}]
    end
  end

  @impl true
  def init(_opts) do
    Supervisor.init(load_config(), strategy: :one_for_one)
  end
end
