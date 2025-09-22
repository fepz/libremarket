

Los campos id_* son de tipo númerico (enteros positivos).

Todas las operaciones deben retornar al cliente el mapa que devuelven esas funciones convertido en JSON.

No es necesario implementar las funciones que se deben invocar, solamente realiza la invocación dado que ya las tengo implementadas.

# Seleccionar producto

Verbo HTTP: PUT

Datos que envia el cliente al servidor: {"id":id_compra,"producto":id_producto}

Debe invocar Compras.Server.seleccionar_producto(id_producto)

# Seleccionar forma de entrega

Verbo HTTP: PUT

Datos que envia el cliente al servidor: {"id":id_compra,"envio":metodo} donde metodo puede ser "correo" o "retira"

Debe invocar Compras.Server.forma_de_entrega(:retira) o Compras.Server.forma_de_entrega(:correo)

Notar que convierte el parametro de tipo entero en el atomo :correo o :retira según corresponda.

# Seleccionar medio de pago

Verbo HTTP: PUT

Datos que envia el cliente al servidor: {"id":id_compra,"pago":medio_de_pago}

Donde medio_de_pago debe ser "efectivo", "transferencia", "td" o "tc" 

Debe invocar: Compras.Server.seleccionar_medio_de_pago(medio_de_pago), convirtiendo el parametro medio_de_pago a un atomo.

# Confirmar compra

Verbo HTTP: PUT

Enviar: {"id":id_compra}

Debe invocar Compras.Server.confirmar_compra(id_compra)

