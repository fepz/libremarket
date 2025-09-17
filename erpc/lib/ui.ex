defmodule Libremarket.Ui do

  def comprar_old(id_producto, forma_de_envio, medio_de_pago) do
    Compras.Server.iniciar_compra
    |> Compras.Server.seleccionar_producto(id_producto)
    |> Compras.Server.seleccionar_forma_entrega(forma_de_envio)
    |> Compras.Server.seleccionar_medio_de_pago(medio_de_pago)
    |> Compras.Server.confirmar_compra
  end

  def comprar(id_producto, forma_de_envio, medio_de_pago) do
    compra = :erpc.call(:"compras@hp", Compras.Server, :iniciar_compra, []);
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_producto, [compra, id_producto]);
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_forma_entrega, [compra, forma_de_envio]);
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_medio_de_pago, [compra, medio_de_pago]);
    :erpc.call(:"compras@hp", Compras.Server, :confirmar_compra, [compra]);
  end

  def comprar_timed(id_producto, forma_de_envio, medio_de_pago) do
    Process.sleep(Enum.random(1..1000))
    compra = :erpc.call(:"compras@hp", Compras.Server, :iniciar_compra, []);
    Process.sleep(Enum.random(1..1000))
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_producto, [compra, id_producto]);
    Process.sleep(Enum.random(1..1000))
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_forma_entrega, [compra, forma_de_envio]);
    Process.sleep(Enum.random(1..1000))
    compra = :erpc.call(:"compras@hp", Compras.Server, :seleccionar_medio_de_pago, [compra, medio_de_pago]);
    Process.sleep(Enum.random(1..1000))
    :erpc.call(:"compras@hp", Compras.Server, :confirmar_compra, [compra]);
  end

end
