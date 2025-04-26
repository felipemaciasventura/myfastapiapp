# myfastapiapp: Guía de Desarrollo y Containerización con FastAPI y Docker Compose

Este repositorio contiene un proyecto básico de ejemplo de FastAPI diseñado para fines de desarrollo y pruebas, junto con una configuración de Docker Compose para containerizar la aplicación. La guía adjunta explica el proceso de configuración local, implementación básica y, fundamentalmente, cómo utilizar Docker Compose para crear un entorno de desarrollo consistente y reproducible.

**Objetivo Principal:** Aprender a configurar y ejecutar una aplicación FastAPI en un entorno de desarrollo local, y luego containerizarla y gestionarla con Docker Compose, enfocándose en un flujo de trabajo eficiente para desarrollo y pruebas.

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalados los siguientes elementos en tu sistema:

* **Python 3.7+**: Para ejecutar la aplicación localmente y crear el entorno virtual.
* **pip**: El gestor de paquetes de Python (suele venir con Python).
* **Docker**: La plataforma de contenedores.
* **Docker Compose**: Una herramienta para definir y ejecutar aplicaciones multi-contenedor de Docker (suele venir incluido con las versiones recientes de Docker Desktop).

## Parte 1: Configuración Inicial y Código FastAPI

Esta parte describe los pasos para configurar el entorno de desarrollo Python y escribir el código de la aplicación.

### 1. Configuración del Entorno Virtual de Python

Se crea un entorno virtual dedicado para el proyecto para aislar las dependencias. Se describe cómo crear un directorio de proyecto, crear el entorno virtual dentro de él y luego activarlo usando los comandos apropiados para tu sistema operativo.

### 2. Instalación de Dependencias Necesarias

Con el entorno virtual activado, se instalan los paquetes Python necesarios para el proyecto: `fastapi`, `uvicorn` (con las extras `[standard]` para funcionalidades adicionales), `jinja2` (para renderizar plantillas HTML) y `python-multipart` (útil para manejar formularios y subidas de archivos). Posteriormente, se genera un archivo `requirements.txt` que lista todas las dependencias instaladas con sus versiones exactas utilizando el comando `pip freeze`.

### 3. Estructura Básica del Proyecto

Se describe la estructura de directorios y archivos del proyecto después de la configuración inicial. La estructura incluye el directorio raíz del proyecto (ej: `myfastapiapp`), un subdirectorio `templates` para archivos HTML, y los archivos principales como `main.py`, `requirements.txt`, `Dockerfile`, y `docker-compose.yml`.

La estructura esperada es similar a esta:

myfastapiapp/
├── main.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── templates/
└── index.html

### 4. Implementación del Archivo `main.py`

Se describe el contenido del archivo `main.py`. Este archivo inicializa la aplicación FastAPI, configura el motor de plantillas Jinja2 y define tres endpoints de ejemplo:

* Un endpoint `GET /items/{item_id}` que acepta un parámetro de ruta entero y un parámetro de consulta opcional, retornando un JSON.
* Un endpoint `POST /greet` que acepta un cuerpo de solicitud JSON con un campo `name` (validado usando Pydantic) y retorna un mensaje de saludo en formato JSON.
* Un endpoint `GET /` que renderiza una plantilla HTML (`index.html`) utilizando Jinja2, pasando algunos datos a la plantilla.

Este archivo contiene la lógica básica de nuestra aplicación de ejemplo.

### 5. Creación de la Plantilla HTML (`templates/index.html`)

Se describe el contenido del archivo `templates/index.html`. Este es un archivo HTML simple que utiliza la sintaxis de Jinja2 para mostrar un mensaje pasado desde el endpoint `/` en `main.py`.

### 6. Ejecución de la Aplicación Localmente

Se explican los pasos para ejecutar la aplicación utilizando Uvicorn directamente en el entorno virtual activado. Se menciona el comando `uvicorn main:app --reload --host 0.0.0.0 --port 8000` y se explica el propósito de cada flag (`--reload` para reinicio automático, `--host 0.0.0.0` para accesibilidad, `--port 8000` para definir el puerto).

### 7. Prueba de Endpoints con `curl`

Se describe cómo utilizar la herramienta de línea de comandos `curl` para enviar solicitudes a los tres endpoints de la aplicación corriendo localmente en `http://127.0.0.1:8000`. Se describen los comandos necesarios para realizar solicitudes GET (con path y query params) y POST (con cuerpo JSON).

### 8. Buenas Prácticas y Tareas Recomendadas (Entorno de Desarrollo Local)

Se enumeran recomendaciones para un entorno de desarrollo más robusto, como:

* Mantener el uso del flag `--reload` de Uvicorn.
* Usar `requirements.txt` para gestión de dependencias.
* Integrar linters y formateadores de código (ej: Flake8, Black).
* Implementar pruebas (ej: con Pytest).
* Utilizar variables de entorno (ej: con `python-dotenv`).
* Aprovechar la documentación automática de FastAPI (`/docs`, `/redoc`).

## Parte 2: Containerización con Docker y Docker Compose

Esta parte describe cómo empaquetar la aplicación en un contenedor Docker y gestionarla con Docker Compose, ideal para replicar el entorno.

### 9. Creación del `Dockerfile`

Se describe el contenido del archivo `Dockerfile`. Este archivo define los pasos para construir la imagen Docker de la aplicación:

* Usa una imagen base ligera de Python.
* Establece un directorio de trabajo dentro del contenedor (`/app`).
* Copia el archivo `requirements.txt`.
* Instala las dependencias usando `pip install`.
* Copia el resto del código de la aplicación al directorio de trabajo.
* Expone el puerto interno donde la aplicación correrá (ej: 80).
* Define el comando por defecto (`CMD`) para iniciar la aplicación con Uvicorn (sin `--reload` aquí, ya que se manejará en Docker Compose para desarrollo).

El `Dockerfile` asegura que la aplicación y sus dependencias se empaqueten de forma consistente.

### 10. Configuración de `docker-compose.yml`

Se describe el contenido del archivo `docker-compose.yml`. Este archivo define los servicios que componen la aplicación (en este caso, un único servicio `web`):

* Especifica la versión de la sintaxis de Compose.
* Define el servicio `web`.
* Indica a Compose que construya la imagen utilizando el `Dockerfile` en el contexto actual.
* Mapea un puerto del host (ej: 8000) a un puerto del contenedor (ej: 80) para poder acceder a la aplicación.
* Configura un **volumen** que monta el directorio actual del código fuente local (`.`) en el directorio de trabajo del contenedor (`/app`). **Este paso es fundamental para el desarrollo**, ya que permite que los cambios en el código local se reflejen instantáneamente dentro del contenedor.
* **Sobrescribe el comando de inicio** definido en el `Dockerfile` para el entorno de desarrollo, añadiendo el flag `--reload` a la llamada a Uvicorn. La combinación del volumen montado y el flag `--reload` habilita el hot-reloading dentro del contenedor.

### 11. Construcción y Ejecución con Docker Compose

Se explican los comandos necesarios para construir la imagen Docker y luego iniciar el servicio `web` utilizando `docker compose`. Se describe el comando para construir (`docker compose build`) y el comando para ejecutar en segundo plano (`docker compose up -d`).

### 12. Verificación y Depuración con Docker Compose

Se describen comandos útiles de Docker Compose para gestionar y depurar el servicio:

* `docker compose ps`: Para verificar el estado de los servicios.
* `docker compose logs <nombre_servicio>`: Para ver la salida de los logs del servicio (con `-f` para seguir en tiempo real).
* `docker compose exec <nombre_servicio> <comando>`: Para ejecutar comandos dentro del contenedor (ej: iniciar un shell `bash` para inspección).
* `docker compose down`: Para detener y eliminar los contenedores, redes y volúmenes creados por Compose.

Se reitera cómo probar los endpoints usando `curl`, ahora apuntando al puerto mapeado por Docker Compose en el host (ej: `http://localhost:8000`).

### 13. Sugerencias Adicionales para Desarrollo con Docker Compose

Se refuerzan las buenas prácticas y ventajas del uso de Docker Compose para desarrollo:

* El uso combinado de **volúmenes** y el flag `--reload` para un ciclo de desarrollo rápido.
* Gestión de variables de entorno.
* La facilidad para integrar **múltiples servicios** (bases de datos, cachés) en un único entorno definido en `docker-compose.yml`.
* La utilidad del archivo `.dockerignore` para optimizar la construcción de imágenes.

## Conclusiones

Esta guía ha cubierto los pasos para establecer un entorno de desarrollo básico para una aplicación FastAPI, crear endpoints de ejemplo y, lo más importante, containerizarla y gestionarla utilizando Docker Compose.

Al emplear Docker Compose con volúmenes y el hot-reloading, se logra un entorno de desarrollo consistente, aislado y ágil que facilita tanto la codificación como las pruebas, y que sirve como una excelente base para entender flujos de trabajo containerizados más complejos. Los comandos de verificación y depuración de Docker Compose son herramientas esenciales para diagnosticar y resolver problemas durante el desarrollo.

Con este proyecto configurado y versionado en Git (excluyendo los archivos innecesarios gracias a `.gitignore`), tienes una base sólida para seguir explorando FastAPI y Docker.
