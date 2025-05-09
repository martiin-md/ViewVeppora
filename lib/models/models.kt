data class Usuario(
    val saldoSimulado: Double = 0.0,
    val saldoReal: Double = 0.0,
    val email: String = "",
    val nombre: String = "",
    val tipoSuscripcion: String = "",
    val fechaRegistro: String = ""
)

data class Transaccion(
    val tipo: String = "",
    val cantidad: Double = 0.0,
    val fecha: String = "",
    val userId: String = ""
)

data class Suscripcion(
    val fechaInicio: String = "",
    val fechaFin: String = "",
    val tipo: String = "",
    val usuarioId: String = ""
)

data class Activo(
    val nombre: String = "",
    val precioActual: Double = 0.0,
    val simbolo: String = "",
    val tipo: String = ""
)
