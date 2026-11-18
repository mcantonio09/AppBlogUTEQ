from contextlib import asynccontextmanager
import hashlib
import hmac
from pathlib import Path
import shutil
import uuid

from fastapi import FastAPI, Depends, UploadFile, File, Form, HTTPException, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from pwdlib import PasswordHash
from pwdlib.exceptions import UnknownHashError

from database import obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

password_hash = PasswordHash.recommended()


def hash_sha512(texto: str) -> str:
    return hashlib.sha512(texto.encode("utf-8")).hexdigest()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

MAMP_BLOG_IMG_DIR = Path("/Applications/MAMP/htdocs/Proyecto_WEB_blog/img/blog_img")
if MAMP_BLOG_IMG_DIR.exists():
    app.mount(
        "/mamp-blog-img",
        StaticFiles(directory=MAMP_BLOG_IMG_DIR),
        name="mamp_blog_img",
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def normalizar_url_img(url_img: str | None, request: Request) -> str | None:
    if not url_img or not url_img.strip():
        return None

    ruta = url_img.strip()
    if ruta.startswith("http://") or ruta.startswith("https://"):
        return ruta

    nombre_archivo = Path(ruta).name
    base = str(request.base_url).rstrip("/")
    return f"{base}/mamp-blog-img/{nombre_archivo}"


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


# USUARIOS

@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    usuario = Usuario(
        nombre=datos.nombre.strip(),
        correo=datos.correo.strip().lower(),
        passwd=hash_sha512(datos.passwd),
        tipo_usr=datos.tipo_usr,
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.put("/usuarios/{usuario_id}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    usuario.nombre = datos.nombre.strip()
    usuario.correo = datos.correo.strip().lower()
    usuario.tipo_usr = datos.tipo_usr

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.delete("/usuarios/{usuario_id}", status_code=204)
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    db.delete(usuario)
    db.commit()

    return None


# BLOG

@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(request: Request, db: Session = Depends(obtener_sesion)):
    publicaciones = db.scalars(
        select(Blog).order_by(Blog.id_blog)
    ).all()

    for pub in publicaciones:
        pub.url_img = normalizar_url_img(pub.url_img, request)

    return publicaciones


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
async def crear_blog(
    request: Request,
    id_usr: int = Form(...),
    titulo: str = Form(...),
    resumen: str = Form(...),
    descripcion: str | None = Form(None),
    etiquetas: str | None = Form(None),
    estado: str = Form("Publicado"),
    imagen: UploadFile | None = File(None),
    db: Session = Depends(obtener_sesion),
):
    if db.get(Usuario, id_usr) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario autor no encontrado",
        )

    url_img: str | None = None
    if imagen is not None and imagen.filename:
        extension = Path(imagen.filename).suffix.lower()
        if extension not in [".jpg", ".jpeg", ".png", ".webp"]:
            raise HTTPException(
                status_code=400,
                detail="Formato de imagen no permitido",
            )

        nombre_archivo = f"{uuid.uuid4().hex}{extension}"
        ruta_archivo = UPLOAD_DIR / nombre_archivo

        with ruta_archivo.open("wb") as destino:
            shutil.copyfileobj(imagen.file, destino)

        base = str(request.base_url).rstrip("/")
        url_img = f"{base}/uploads/{nombre_archivo}"

    nueva_publicacion = Blog(
        id_usr=id_usr,
        titulo=titulo.strip(),
        resumen=resumen.strip(),
        descripcion=(
            descripcion.strip()
            if descripcion and descripcion.strip()
            else None
        ),
        etiquetas=(
            etiquetas.strip()
            if etiquetas and etiquetas.strip()
            else None
        ),
        url_img=url_img,
        estado=estado.strip(),
    )

    db.add(nueva_publicacion)
    db.commit()
    db.refresh(nueva_publicacion)

    return nueva_publicacion


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(
    blog_id: int,
    request: Request,
    db: Session = Depends(obtener_sesion),
):
    publicacion = db.get(Blog, blog_id)

    if publicacion is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    publicacion.url_img = normalizar_url_img(publicacion.url_img, request)
    return publicacion


# COMENTARIOS

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Comentario).order_by(Comentario.id_comentario)
    ).all()


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Usuario, datos.id_usr) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    if db.get(Blog, datos.id_blog) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        id_usr=datos.id_usr,
        id_blog=datos.id_blog,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo


# LOGIN

@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.correo.strip().lower()
    usuario = db.scalar(
        select(Usuario).where(Usuario.correo == correo)
    )

    if usuario is None:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    contrasena_valida = hmac.compare_digest(
        usuario.passwd.lower(),
        hash_sha512(datos.passwd),
    )

    if not contrasena_valida:
        try:
            contrasena_valida = password_hash.verify(
                datos.passwd,
                usuario.passwd,
            )
        except UnknownHashError:
            contrasena_valida = False

    if not contrasena_valida:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    return usuario