defmodule Infracciones do
  @moduledoc """
  Logica de Infracciones
  """

  def detectar_infraccion() do
    random_number = :rand.uniform(100)
    if random_number <= 30 do
      true
    else
      false
    end
  end

end

defmodule Infracciones.Server do
  @moduledoc """
  Servidor de infracciones
  """

  use GenServer

  # API del cliente

  @doc """
  Crea un nuevo servidor de Infracciones
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def detectar_infraccion(id_compra) do
    GenServer.call(__MODULE__, {:detectar_infraccion, id_compra})
  end

  def listar_infracciones() do
    GenServer.call(__MODULE__, :listar_infracciones)
  end

  def inspeccionar_infraccion(id) do
    GenServer.call(__MODULE__, {:inspeccionar, id})
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
  def handle_call({:detectar_infraccion, id_compra}, _from, state) do
    infraccion = Infracciones.detectar_infraccion
    new_state = Map.put(state, id_compra, infraccion)
    {:reply, infraccion, new_state}
  end

  @impl true
  def handle_call(:listar_infracciones, _from, state) do
    {:reply, state, state}
  end

end
