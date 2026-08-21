defmodule LibremarketSupervisor do
  use Supervisor

  @doc """
  Inicia el supervisor
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp load_config() do
    [
      {Compras.Server, %{}},
      {Envios.Server, %{}},
      {Infracciones.Server, %{}},
      {Pagos.Server, %{}},
      {Ventas.Server, %{}}
    ]
  end

  @impl true
  def init(_opts) do
    Supervisor.init(load_config(), strategy: :one_for_one)
  end
end
