defmodule Compras.Server do
  @moduledoc """
  Compras
  """

  use GenServer

  # API del cliente

  @doc """
  Crea un nuevo servidor de Compras
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def iniciar_compra do
    GenServer.call(__MODULE__, :iniciar_compra)
  end

  def seleccionar_producto(compra, id_producto) do
    GenServer.call(__MODULE__, {:seleccionar_producto, compra, id_producto})
  end

  def seleccionar_forma_entrega(compra, forma_de_entrega) do
    GenServer.call(__MODULE__, {:seleccionar_forma_entrega, compra, forma_de_entrega})
  end

  def seleccionar_medio_de_pago(compra, medio_de_pago) do
    GenServer.call(__MODULE__, {:seleccionar_medio_de_pago, compra, medio_de_pago})
  end

  def confirmar_compra(compra) do
    GenServer.call(__MODULE__, {:confirmar_compra, compra})
  end

  def listar_compras() do
    GenServer.call(__MODULE__, :listar_compras)
  end

  def obtener_compra(id_compra) do
    GenServer.call(__MODULE__, {:obtener_compra, id_compra})
  end

  # Callbacks

  @doc """
  Inicializa el estado del servidor
  """
  @impl true
  def init(state) do
    {:ok, %{counter: 1, compras: state}}
  end

  @impl true
  def handle_call(:iniciar_compra, _from, state) do
    new_compra = Compras.iniciar_compra(state.counter)
    lista_compras = Map.put(state.compras, new_compra.id, new_compra)
    {:reply, new_compra, %{counter: state.counter + 1, compras: lista_compras}}
  end

  @impl true
  def handle_call({:seleccionar_producto, compra, id_producto}, _from, state) do
    updated_compra = Compras.seleccionar_producto(compra, id_producto)
    new_state = %{state | compras: Map.put(state.compras, compra.id, updated_compra)}
    {:reply, updated_compra, new_state}
  end

  @impl true
  def handle_call({:seleccionar_forma_entrega, compra, forma_de_entrega}, _from, state) do
    updated_compra = Compras.seleccionar_forma_entrega(compra, forma_de_entrega)
    new_state = %{state | compras: Map.put(state.compras, compra.id, updated_compra)}
    {:reply, updated_compra, new_state}
  end

  @impl true
  def handle_call({:seleccionar_medio_de_pago, compra, medio_de_pago}, _from, state) do
    updated_compra = Compras.seleccionar_medio_pago(compra, medio_de_pago)
    new_state = %{state | compras: Map.put(state.compras, compra.id, updated_compra)}
    {:reply, updated_compra, new_state}
  end

  def handle_call({:confirmar_compra, compra}, _from, state) do
    updated_compra = Compras.confirmar_compra(compra)
    new_state = %{state | compras: Map.put(state.compras, compra.id, updated_compra)}
    {:reply, updated_compra, new_state}
  end

  @impl true
  def handle_call(:listar_compras, _from, state) do
    {:reply, state.compras, state}
  end

  @impl true
  def handle_call({:obtener_compra, id_compra}, _from, state) do
    compra = Map.get(state.compras, id_compra)
    {:reply, compra, state}
  end

end
