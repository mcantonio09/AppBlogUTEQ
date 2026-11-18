from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    Date,
    DateTime,
    ForeignKey,
    func,
)
from database import Base


class Usuario(Base):
    __tablename__ = "usuario"

    id_usr = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    correo = Column(String(100), unique=True, nullable=False)
    passwd = Column(String(255), nullable=False)
    tipo_usr = Column(Integer, nullable=True, default=1)


class Blog(Base):
    __tablename__ = "blog"

    id_blog = Column(Integer, primary_key=True, index=True)
    id_usr = Column(
        Integer,
        ForeignKey("usuario.id_usr"),
        nullable=False,
    )
    fecha_creacion = Column(
        Date,
        nullable=False,
        server_default=func.current_date(),
    )
    titulo = Column(String(255), nullable=False)
    resumen = Column(String(255), nullable=False)
    descripcion = Column(Text, nullable=True)
    etiquetas = Column(String(255), nullable=True)
    url_img = Column(String(500), nullable=True)
    estado = Column(String(255), nullable=False)


class Comentario(Base):
    __tablename__ = "comentarios"

    id_comentario = Column(Integer, primary_key=True, index=True)
    id_usr = Column(
        Integer,
        ForeignKey("usuario.id_usr"),
        nullable=False,
    )
    id_blog = Column(
        Integer,
        ForeignKey("blog.id_blog"),
        nullable=False,
    )
    comentario = Column(Text, nullable=False)
    fecha_comentario = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )