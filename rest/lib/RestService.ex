defmodule Libremarket.RestService do
  use Plug.Router
  import Plug.Conn

  # Analiza el cuerpo de la peticion y pone los datos en `conn.body_params`.
  plug Plug.Parsers,
     parsers: [:urlencoded, :json],
     json_decoder: Jason

  # Busca una ruta que coincida con la petición (ejemplo: GET /compra/1).
  plug :match

  # Si :match encontró una ruta coincidente, llama a la función correcta.
  plug :dispatch

  # Recupera información de la compra con identificador id
  get "/compra/:id" do
    id = String.to_integer(id)
    compra = Compras.Server.obtener_compra(id)
    json_response = Jason.encode!(compra)
    send_resp(conn, 200, json_response)
  end

  # Crea una compra
  post "/compra" do
    compra = Compras.Server.iniciar_compra()
    json_response = Jason.encode!(compra)
    send_resp(conn, 200, json_response)
  end

  # Actualiza información de la compra con identificador id
  put "/compra/:id" do
    case Integer.parse(id) do
      {id_int, ""} ->
        with compra <- Compras.Server.obtener_compra(id_int),
             {:ok, compra} <- actualizar_compra(compra, conn.body_params) do
          json_response = Jason.encode!(compra)
          send_resp(conn, 200, json_response)
        else
          {:error, :not_found} ->
            send_resp(conn, 404, "Compra no encontrada")
          {:error, :invalid_param} ->
            send_resp(conn, 400, "Parámetros de entrada no válidos")
          {:error, _reason} ->
            send_resp(conn, 500, "Error interno del servidor")
        end
      _ ->
        send_resp(conn, 400, "ID de compra no válido")
    end

  end
   
  defp actualizar_compra(compra, params) do
    compra
    |> seleccionar_producto(params)
    |> seleccionar_forma_entrega(params)
    |> seleccionar_medio_de_pago(params)
  end

  defp seleccionar_producto(compra, params) do
    if (producto_id_str = Map.get(params, "producto_id")) do
      case Integer.parse(producto_id_str) do
        {producto_id, ""} -> {:ok, Compras.Server.seleccionar_producto(compra, producto_id)}
        _ -> {:error, :invalid_param}
      end
    else
      {:ok, compra}
    end
  end

  defp seleccionar_forma_entrega(compra, params) do
    case compra do
      {:ok, compra} ->
        case Map.get(params, "entrega") do
          "correo" -> {:ok, Compras.Server.seleccionar_forma_entrega(compra, :correo)}
          "retira" -> {:ok, Compras.Server.seleccionar_forma_entrega(compra, :retira)}
          nil -> {:ok, compra}
          _ -> {:error, :invalid_param}
        end
      {:error, _} -> {:error, :invalid_param}
    end
  end

  defp seleccionar_medio_de_pago(compra, params) do
    case compra do
      {:ok, compra} ->
        if (medio_de_pago = Map.get(params, "pago")) do
          case medio_de_pago do
            "tc" -> {:ok, Compras.Server.seleccionar_medio_de_pago(compra, :tc)}
            "td" -> {:ok, Compras.Server.seleccionar_medio_de_pago(compra, :td)}
            "efectivo" -> {:ok, Compras.Server.seleccionar_medio_de_pago(compra, :efectivo)}
            "transferencia" -> {:ok, Compras.Server.seleccionar_medio_de_pago(compra, :transferencia)}
            _ -> {:error, :invalid_param}
          end
        else
          {:ok, compra}
        end
      {:error, _} -> {:error, :invalid_param}
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
