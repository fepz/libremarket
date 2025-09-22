defmodule Pagos do

  def autorizar_pago() do
    Enum.random(0 .. 100) > 30
  end

end

defmodule Pagos.Server do
  @moduledoc """
  Compras
  """

  use GenServer

  @global_name {:global, __MODULE__}

  # API del cliente

  @doc """
  Crea un nuevo servidor de Pagos
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: @global_name)
  end

  def autorizar_pago(id_compra) do
    GenServer.call(@global_name, {:autorizar_pago, id_compra})
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
  Callback para autorizar pago
  """
  @impl true
  def handle_call({:autorizar_pago, id_compra}, _from, state) do
    autorizado = Pagos.autorizar_pago()
    new_state = Map.put(state, id_compra, autorizado)
    {:reply, autorizado, new_state}
  end

end
