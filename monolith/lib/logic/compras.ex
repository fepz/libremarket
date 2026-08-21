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

  def seleccionar_producto(%Compra{} = compra, id_producto) do
    %{compra | producto: %{id: id_producto, reservado: nil} }
  end

  def seleccionar_forma_entrega(%Compra{} = compra, forma_de_entrega) do
    case forma_de_entrega do
      :retira -> %{compra | envio: %{:metodo => :retira, :costo => 0}}
      :correo -> %{compra | envio: %{:metodo => :correo, :costo => Envios.Server.calcular_costo(compra.id)}}
    end
  end

  def seleccionar_medio_pago(%Compra{} = compra, medio_de_pago) do
    %{compra | pago: %{:medio_de_pago => medio_de_pago, autorizado: nil}}
  end

  defp reservar_producto(%Compra{} = compra) do
    reserva = Ventas.Server.reservar_producto(compra.producto.id)
    compra = %{compra | producto: %{compra.producto | reservado: reserva}}
    {reserva, compra}
  end

  defp detectar_infraccion(%Compra{} = compra) do
    infraccion = Infracciones.Server.detectar_infraccion(compra.producto.id)
    compra = %{compra | infraccion: infraccion}
    {infraccion, compra}
  end

  defp autorizar_pago(%Compra{} = compra) do
    pago = Pagos.Server.autorizar_pago(compra.producto.id)
    compra = %{compra | pago: %{compra.pago | autorizado: pago}}
    {pago, compra}
  end

  def confirmar_compra(%Compra{} = compra) do
    with {true, compra} <- reservar_producto(compra),
         {false, compra} <- detectar_infraccion(compra),
         {true, compra} <- autorizar_pago(compra)
    do
      if compra.envio.metodo == :correo do
        Envios.Server.agendar_envio(compra.id)
      end
      %{compra | estado: :ok}
    else
      {_, compra} -> %{compra | estado: :error}
    end
  end

end
