class Registro {
  int? id;
  String nombre;
  String correo;
  String direccion;
  String fechaNacimiento;
  String password;

  Registro({
    this.id,
    required this.nombre,
    required this.correo,
    required this.direccion,
    required this.fechaNacimiento,
    required this.password,
  });

  // Convertir un objeto Registro a un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'direccion': direccion,
      'fechaNacimiento': fechaNacimiento,
      'password': password,
    };
  }

  // Crear un objeto Registro
  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      direccion: map['direccion'],
      fechaNacimiento: map['fechaNacimiento'],
      password: map['password'],
    );
  }
}
