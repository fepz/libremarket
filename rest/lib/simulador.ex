defmodule Simulador do

  def simular_compra(id) do
    envio = Enum.random([:retira, :correo])
    pago = Enum.random([:efectivo, :transferencia, :td, :tc])
    Libremarket.Ui.comprar(id, envio, pago)
  end

  def simular_compra_timed(id) do
    envio = Enum.random([:retira, :correo])
    pago = Enum.random([:efectivo, :transferencia, :td, :tc])
    Libremarket.Ui.comprar_timed(id, envio, pago)
  end

  def simular_compras_secuencial(cantidad \\ 1) do
    for n <- 1 .. cantidad do
      simular_compra(n)
    end
  end

  def simular_compras_async(cantidad \\ 1) do
    compras = for n <- 1 .. cantidad do
      Task.async(fn -> simular_compra(n) end)
    end
    Task.await_many(compras)
  end

  def simular_compras_async_wait(cantidad \\ 1) do
    compras = for n <- 1 .. cantidad do
      Task.async(fn -> simular_compra_timed(n) end)
    end
    Task.await_many(compras)
  end

end
