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
