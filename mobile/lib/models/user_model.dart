class UserModel {
  final int id;
  final String nombre;
  final String correo;
  final String? password;
  final int tipoUsuario;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.tipoUsuario = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id_usr'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      tipoUsuario: (json['tipo_usr'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'nombre': nombre,
      'correo': correo,
      'passwd': password,
      'tipo_usr': tipoUsuario,
    };
  }
}