# myfastapiapp/Dockerfile

# Usa una imagen base ligera con Python
FROM python:3.10-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el archivo requirements.txt al directorio de trabajo
COPY requirements.txt ./

# Instala las dependencias.
# El flag --no-cache-dir es bueno para no guardar caché de pip innecesario en la imagen.
# El flag -r especifica el archivo de requerimientos.
RUN pip install --no-cache-dir -r requirements.txt

# Copia todo el contenido del directorio actual (tu código) al directorio de trabajo en el contenedor
COPY . /app

# Expone el puerto en el que correrá la aplicación dentro del contenedor
EXPOSE 80

# Comando para ejecutar la aplicación con Uvicorn
# --host 0.0.0.0 es necesario para que la aplicación sea accesible desde fuera del contenedor
# --port 80 especifica el puerto dentro del contenedor (mapearemos 8000 del host a este)
# NO usaremos --reload aquí, lo haremos en docker-compose.yml para desarrollo
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]

# Nota sobre CMD vs ENTRYPOINT: CMD es el comando por defecto que se ejecuta.
# Puede ser fácilmente sobrescrito al ejecutar el contenedor.
# ENTRYPOINT es más para definir el comando principal del contenedor,
# y los argumentos pasados al run se adjuntan a él. CMD es más flexible para nuestro caso.