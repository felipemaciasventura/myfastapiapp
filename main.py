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
