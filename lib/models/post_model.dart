class PostModel {
  final int id;
  final int usuarioId;
  final String fechaCreacion;
  final String titulo;
  final String resumen;
  final String descripcion;
  final String imagen;
  final String tags;
  final String estado;

  const PostModel({
    required this.id,
    required this.usuarioId,
    required this.fechaCreacion,
    required this.titulo,
    required this.resumen,
    required this.descripcion,
    required this.imagen,
    required this.tags,
    required this.estado,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id_blog'] as num).toInt(),
      usuarioId: (json['id_usr'] as num).toInt(),
      fechaCreacion: json['fecha_creacion']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      resumen: json['resumen']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      imagen: json['url_img']?.toString() ?? '',
      tags: json['etiquetas']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'id_usr': usuarioId,
      'titulo': titulo,
      'resumen': resumen,
      'descripcion': descripcion,
      'etiquetas': tags,
      'url_img': imagen,
      'estado': estado,
    };
  }
}