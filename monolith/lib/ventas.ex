defmodule Ventas do

  def reservar_producto() do
    true
  end

  def liberar_producto() do
    :ok
  end

  def enviar_producto() do
    :ok
  end

end

defmodule Ventas.Server do
  @moduledoc """
  Compras
  """

  use GenServer

  # API del cliente

  @doc """
  Crea un nuevo servidor de Ventas
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def reservar_producto(_id_producto) do
    GenServer.call(__MODULE__, :reservar_producto)
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
  Callback para realizar compra
  """
  @impl true
  def handle_call(:reservar_producto, _from, state) do
    {:reply, Ventas.reservar_producto(), state}
  end

end
