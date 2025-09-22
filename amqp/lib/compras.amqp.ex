defmodule Compras.AMQP do
  use GenServer
  use AMQP

  def detectar_infraccion(id_compra) do
    GenServer.cast(__MODULE__, {:detectar_infraccion, id_compra})
  end

  def reservar_producto(id_compra, id_producto) do
    GenServer.cast(__MODULE__, {:reservar_producto, id_compra, id_producto})
  end

  def agendar_envio(id_compra, id_producto) do
    GenServer.cast(__MODULE__, {:agendar_envio, id_compra, id_producto})
  end

  def calcular_costo(id_compra, id_producto) do
    GenServer.cast(__MODULE__, {:calcular_costo, id_compra, id_producto})
  end

  # AMQP
  @queue "compras"

  @doc """
  Crea un nuevo servidor de Compras.AMQP
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    url = case System.get_env("AMQP_URL") do
      nil -> ""
      url -> url
    end
    {:ok, conn} = Connection.open(url, ssl_options: [verify: :verify_none])
    {:ok, chan} = Channel.open(conn)
    {:ok, _} = Queue.declare(chan, @queue, auto_delete: true)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, @queue, nil, no_ack: true)
    {:ok, chan}
  end

  @impl true
  def handle_cast({:detectar_infraccion, id_compra}, chan) do
    Basic.publish(chan, "", "infracciones", :binary.encode_unsigned(id_compra))
    {:noreply, chan}
  end

  @impl true
  def handle_cast({:reservar_producto, id_compra, id_producto}, chan) do
    Basic.publish(chan, "", "ventas", :erlang.term_to_binary({id_compra, id_producto}))
    {:noreply, chan}
  end

  @impl true
  def handle_cast({:agendar_envio, id_compra, id_producto}, chan) do
    Basic.publish(chan, "", "envios", :erlang.term_to_binary({id_compra, id_producto}), correlation_id: "agendar")
    {:noreply, chan}
  end

  @impl true
  def handle_cast({:calcular_costo, id_compra, id_producto}, chan) do
    Basic.publish(chan, "", "envios", :erlang.term_to_binary({id_compra, id_producto}), correlation_id: "costo")
    {:noreply, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  @impl true
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  @impl true
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  @impl true
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  @impl true
  def handle_info({:basic_deliver, payload, %{delivery_tag: _tag, redelivered: _redelivered, correlation_id: id}}, chan) do
    case id do
      "infracciones" ->
        resultado = :erlang.binary_to_term(payload)
        Compras.Server.actualizar_infraccion(resultado)
      "ventas" ->
        resultado = :erlang.binary_to_term(payload)
        Compras.Server.actualizar_reserva(resultado)
      "envios" ->
        resultado = :erlang.binary_to_term(payload)
        Compras.Server.actualizar_costo_envio(resultado)
    end
    # You might want to run payload consumption in separate Tasks in production
    {:noreply, chan}
  end
end
