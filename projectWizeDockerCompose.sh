#!/bin/bash

# --- Configuración ---
PROJECT_DIR="myfastapiapp"
VENV_DIR="venv"
PYTHON_CMD="python3" # O 'python' si python3 es tu comando principal

# --- Funciones de Ayuda ---

# Función para imprimir mensajes de estado
print_status() {
    echo "--- $1 ---"
}

# Función para imprimir mensajes de error y salir
print_error_and_exit() {
    echo "!!! ERROR: $1" >&2
    exit 1
}

# --- Proceso de Automatización ---

print_status "Iniciando configuración del proyecto FastAPI en $PROJECT_DIR"

# 1. Crear directorio del proyecto y navegar a él
if [ -d "$PROJECT_DIR" ]; then
    print_status "El directorio $PROJECT_DIR ya existe. Saltando creación."
else
    print_status "Creando directorio del proyecto: $PROJECT_DIR"
    mkdir "$PROJECT_DIR" || print_error_and_exit "Fallo al crear el directorio $PROJECT_DIR"
fi

print_status "Navegando al directorio del proyecto: $PROJECT_DIR"
cd "$PROJECT_DIR" || print_error_and_exit "Fallo al navegar al directorio $PROJECT_DIR"

# 2. Crear y activar un entorno virtual
print_status "Creando entorno virtual en .$VENV_DIR"
# Verifica si python3 está disponible
if ! command -v "$PYTHON_CMD" &> /dev/null; then
    print_error_and_exit "$PYTHON_CMD no encontrado. Asegúrate de que Python 3 está instalado y en tu PATH."
fi

"$PYTHON_CMD" -m venv "$VENV_DIR" || print_error_and_exit "Fallo al crear el entorno virtual"

print_status "Activando entorno virtual (solo dentro de este script)"
# Activar el entorno virtual para que pip instale allí
# Esto NO activa el venv en tu terminal después de que el script termine
if [ -f "./$VENV_DIR/bin/activate" ]; then
    source "./$VENV_DIR/bin/activate"
elif [ -f "./$VENV_DIR/Scripts/activate" ]; then
    # Manejo básico para Windows (WSL o git bash)
    source "./$VENV_DIR/Scripts/activate"
else
    print_error_and_exit "No se encontró el script de activación del entorno virtual."
fi

print_status "Entorno virtual activado temporalmente."

# 3. Instalación de dependencias
print_status "Instalando dependencias (fastapi, uvicorn[standard], jinja2, python-multipart)"
pip install fastapi uvicorn[standard] jinja2 python-multipart || print_error_and_exit "Fallo al instalar dependencias con pip"

print_status "Generando requirements.txt"
pip freeze > requirements.txt || print_error_and_exit "Fallo al generar requirements.txt"

# 4. Creación de la estructura básica y archivos
print_status "Creando directorio 'templates'"
mkdir -p templates || print_error_and_exit "Fallo al crear el directorio 'templates'"

print_status "Creando archivo main.py"
cat <<EOF > main.py
# myfastapiapp/main.py
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel # Necesario para validar datos en el endpoint POST

# Inicializa la aplicación FastAPI
app = FastAPI()

# Configura el motor de plantillas Jinja2
templates = Jinja2Templates(directory="templates")

# Modelo para los datos de entrada del endpoint POST
class GreetingRequest(BaseModel):
    name: str

# --- Endpoints ---

# 1. Endpoint RESTful de ejemplo con path parameter (GET)
@app.get("/items/{item_id}")
async def read_item(item_id: int, query_param: str | None = None):
    """
    Endpoint que devuelve información de un ítem por su ID.
    Acepta un parámetro de ruta (item_id) y un parámetro de query opcional.
    """
    if item_id <= 0:
        raise HTTPException(status_code=400, detail="Item ID must be positive")

    item_data = {"item_id": item_id}
    if query_param:
        item_data["query_param"] = query_param

    return item_data

# 2. Endpoint RESTful de ejemplo con request body (POST)
@app.post("/greet")
async def greet_user(greeting: GreetingRequest):
    """
    Endpoint que recibe un nombre en el cuerpo de la solicitud (JSON)
    y devuelve un saludo.
    """
    return {"message": f"Hello, {greeting.name}!"}

# 3. Endpoint que renderiza una vista HTML (GET)
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """
    Endpoint que renderiza la plantilla HTML de inicio.
    """
    return templates.TemplateResponse("index.html", {"request": request, "message": "¡Bienvenido a FastAPI!"})
EOF
if [ ! -f main.py ]; then print_error_and_exit "Fallo al crear main.py"; fi

print_status "Creando archivo templates/index.html"
cat <<EOF > templates/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FastAPI Demo</title>
</head>
<body>
    <h1>{{ message }}</h1>
    <p>Esta es una página de ejemplo renderizada por FastAPI usando Jinja2.</p>
    <p>Puedes probar los siguientes endpoints:</p>
    <ul>
        <li><code>GET /items/{item_id}</code> (ej: <a href="/items/123">/items/123</a>)</li>
        <li><code>POST /greet</code> (con cuerpo JSON <code>{"name": "Tu Nombre"}</code>)</li>
        <li><code>GET /</code> (esta página)</li>
    </ul>
</body>
</html>
EOF
if [ ! -f templates/index.html ]; then print_error_and_exit "Fallo al crear templates/index.html"; fi

print_status "Desactivando entorno virtual (saliendo del script)"
deactivate # Desactiva el venv dentro del contexto del script

print_status "Automatización de la Parte 1 completada exitosamente."

# --- Instrucciones Finales para el Usuario ---
echo ""
echo "----------------------------------------------------"
echo "Proyecto '$PROJECT_DIR' configurado."
echo ""
echo "Para ejecutar la aplicación localmente:"
echo "1. Navega al directorio del proyecto:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. Activa el entorno virtual:"
echo "   # En macOS y Linux:"
echo "   source $VENV_DIR/bin/activate"
echo "   # En Windows (Command Prompt):"
echo "   # .$VENV_DIR\Scripts\activate.bat"
echo "   # En Windows (PowerShell):"
echo "   # .$VENV_DIR\Scripts\Activate.ps1"
echo ""
echo "3. Ejecuta la aplicación con Uvicorn:"
echo "   uvicorn main:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "La aplicación estará disponible en http://127.0.0.1:8000"
echo ""
echo "Para desactivar el entorno virtual cuando termines:"
echo "   deactivate"
echo "----------------------------------------------------"
