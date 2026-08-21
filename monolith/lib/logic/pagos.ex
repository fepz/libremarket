defmodule Pagos do

  def autorizar_pago() do
    Enum.random(0 .. 100) > 30
  end

end
