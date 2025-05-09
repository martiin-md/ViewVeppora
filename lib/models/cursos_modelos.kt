class Curso {
  final String nombre;
  final String descripcion;
  final String nivel;

  Curso({
    required this.nombre,
    required this.descripcion,
    required this.nivel,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      nivel: json['nivel'],
    );
  }
}

class Modulo {
  final String nombre;
  final List<Leccion> lecciones;

  Modulo({
    required this.nombre,
    required this.lecciones,
  });

  factory Modulo.fromJson(Map<String, dynamic> json) {
    final leccionesJson = json['lecciones'] as List<dynamic>;
    final lecciones = leccionesJson.map((e) => Leccion.fromJson(e)).toList();
    return Modulo(
      nombre: json['nombre'],
      lecciones: lecciones,
    );
  }
}

class Leccion {
  final String nombre;
  final String descripcion;
  final int orden;
  fnial String contenido;

  Leccion({
    required this.nombre,
    required this.descripcion,
    required this.orden,
    required this.contenido,
  });

  factory Leccion.fromJson(Map<String, dynamic> json) {
    return Leccion(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      orden: json['orden'],
      contenido: json['contenido'],
    );
  }
}