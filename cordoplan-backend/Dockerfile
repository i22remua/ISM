# cordoplan-backend/Dockerfile
# Usar una imagen base de Node.js
FROM node:20-alpine

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copiar archivos de configuración para instalar dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código, incluyendo la carpeta 'src' y 'init_db'
COPY . .

# Exponer el puerto
EXPOSE 3000

# El comando de inicio usa 'npm start' definido en package.json (que apunta a src/app.js)
CMD [ "npm", "start" ]