from datetime import date, datetime
from pydantic import BaseModel, ConfigDict, Field


class UsuarioCrear(BaseModel):
    nombre: str = Field(min_length=2, max_length=100)
    correo: str = Field(min_length=5, max_length=100)
    passwd: str = Field(min_length=8, max_length=128)
    tipo_usr: int | None = 1


class UsuarioActualizar(BaseModel):
    nombre: str = Field(min_length=2, max_length=100)
    correo: str = Field(min_length=5, max_length=100)
    tipo_usr: int | None = 1

    model_config = ConfigDict(from_attributes=True)


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nombre: str
    correo: str
    tipo_usr: int | None = 1

    model_config = ConfigDict(from_attributes=True)


class LoginRequest(BaseModel):
    correo: str = Field(min_length=5, max_length=100)
    passwd: str = Field(min_length=1, max_length=128)


class BlogCrear(BaseModel):
    id_usr: int
    titulo: str = Field(min_length=1, max_length=255)
    resumen: str = Field(min_length=1, max_length=255)
    descripcion: str | None = None
    etiquetas: str | None = None
    url_img: str | None = None
    estado: str = Field(default="Publicado", max_length=255)


class BlogRespuesta(BaseModel):
    id_blog: int
    id_usr: int
    fecha_creacion: date
    titulo: str
    resumen: str
    descripcion: str | None = None
    etiquetas: str | None = None
    url_img: str | None = None
    estado: str

    model_config = ConfigDict(from_attributes=True)


class ComentarioCrear(BaseModel):
    comentario: str = Field(min_length=1)
    id_usr: int
    id_blog: int


class ComentarioRespuesta(BaseModel):
    id_comentario: int
    id_usr: int
    id_blog: int
    comentario: str
    fecha_comentario: datetime
    nombre_usr: str |  None = None

    model_config = ConfigDict(from_attributes=True)