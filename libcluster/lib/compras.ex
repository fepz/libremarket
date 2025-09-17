defmodule Compra do
  # Un defstruct se basa en Maps (~ diccionarios en Python, x ejemplo).
  # Ventaja: chequeos en tiempo de compilación y valores por defecto.
  defstruct [
    :id,
    :producto,
    :infraccion,
    :envio,
    :pago,
    :estado
    ]
end

defmodule Compras do

  # Retorna una compra con el id especificado
  def iniciar_compra(id_compra) do
    %Compra{id: id_compra}
  end

  def seleccionar_producto(compra, id_producto) do
    %Compra{compra | producto: %{id: id_producto, reservado: nil} }
  end

  def seleccionar_forma_entrega(compra, forma_de_entrega) do
    case forma_de_entrega do
      :retira -> %Compra{compra | envio: %{:metodo => :retira, :costo => 0}}
      :correo -> %Compra{compra | envio: %{:metodo => :correo, :costo => Envios.Server.calcular_costo(compra.id)}}
    end
  end

  def seleccionar_medio_pago(compra, medio_de_pago) do
    %Compra{compra | pago: %{:medio_de_pago => medio_de_pago, autorizado: nil}}
  end

  defp reservar_producto(compra) do
    reserva = Ventas.Server.reservar_producto(compra.producto.id)
    compra = %Compra{compra | producto: %{compra.producto | reservado: reserva}}
    {reserva, compra}
  end

  defp detectar_infraccion(compra) do
    infraccion = Infracciones.Server.detectar_infraccion(compra.producto.id)
    compra = %Compra{compra | infraccion: infraccion}
    {infraccion, compra}
  end

  defp autorizar_pago(compra) do
    pago = Pagos.Server.autorizar_pago(compra.producto.id)
    compra = %Compra{compra | pago: %{compra.pago | autorizado: pago}}
    {pago, compra}
  end

  def confirmar_compra(compra) do
    with {true, compra} <- reservar_producto(compra),
         {false, compra} <- detectar_infraccion(compra),
         {true, compra} <- autorizar_pago(compra)
    do
      if compra.envio.metodo == :correo do
        Envios.Server.agendar_envio(compra.id)
      end
      %Compra{compra | estado: :ok}
    else
      {_, compra} -> %Compra{compra | estado: :error}
    end
  end

end

defmodule Compras.Server do
  @moduledoc """
  Compras
  """

  use GenServer

  @global_name {:global, __MODULE__}

  # API del cliente

  @doc """
  Crea un nuevo servidor de Compras
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: @global_name)
  end

  def iniciar_compra do
    GenServer.call(@global_name, :iniciar_compra)
  end

  def seleccionar_producto(compra, id_producto) do
    GenServer.call(@global_name, {:seleccionar_producto, compra, id_producto})
  end

  def seleccionar_forma_entrega(compra, forma_de_entrega) do
    GenServer.call(@global_name, {:seleccionar_forma_entrega, compra, forma_de_entrega})
  end

  def seleccionar_medio_de_pago(compra, medio_de_pago) do
    GenServer.call(@global_name, {:seleccionar_medio_de_pago, compra, medio_de_pago})
  end

  def confirmar_compra(compra) do
    GenServer.call(@global_name, {:confirmar_compra, compra})
  end

  def listar_compras() do
    GenServer.call(@global_name, :listar_compras)
  end

  def obtener_compra(id_compra) do
    GenServer.call(@global_name, {:obtener_compra, id_compra})
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
