defmodule Envios do
  def calcular_costo do
    Enum.random(100 .. 1000)
  end

  def agendar_envio do
    :ok
  end
end

defmodule Envios.Server do
  @moduledoc """
  Compras
  """

  use GenServer

  @global_name {:global, __MODULE__}

  # API del cliente

  @doc """
  Crea un nuevo servidor de envios
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: @global_name)
  end

  def calcular_costo(id_compra) do
    GenServer.call(@global_name, {:calcular_costo, id_compra})
  end

  def agendar_envio(id_compra) do
    GenServer.call(@global_name, {:agendar_envio, id_compra})
  end

  def listar_envios() do
    GenServer.call(@global_name, :listar_envios)
  end

  # Callbacks

  @doc """
  Inicializa el estado del servidor
  """
  @impl true
  def init(state) do
    {:ok, state}
  end

  @doc """
  Callbacks
  """
  @impl true
  def handle_call({:calcular_costo, id_compra}, _from, state) do
    costo = Envios.calcular_costo
    new_state = Map.put(state, id_compra, %{costo: costo, agendado: nil})
    {:reply, costo, new_state}
  end

  @impl true
  def handle_call({:agendar_envio, id_compra}, _from, state) do
    agendado = Envios.agendar_envio
    compra = %{Map.get(state, id_compra) | agendado: agendado}
    new_state = Map.put(state, id_compra, compra)
    {:reply, agendado, new_state}
  end

  @impl true
  def handle_call(:listar_envios, _from, state) do
    {:reply, state, state}
  end

end
