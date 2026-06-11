# DB Schema Downloader for VS Code (Global Task)

Este proyecto permite automatizar la descarga y actualización del esquema estructural (`.sql`) de una base de datos remota MariaDB/MySQL conectada a través de un túnel SSH, directamente en la raíz del espacio de trabajo activo en VS Code. 

El objetivo principal es mantener un archivo de contexto de base de datos siempre actualizado con marca de tiempo para alimentar herramientas de Inteligencia Artificial como **Gemini Code Assist**, optimizando el desarrollo de software.

## 🚀 Características
* **Historial por marcas de tiempo:** Cada descarga genera un archivo único con el formato `schema_AAAA-MM-DD_HH-mm.sql`.
* **Seguridad:** Soporta conexión remota mediante llaves SSH públicas (`id_rsa.pub`) o contraseña.
* **Configuración Desacoplada:** La lógica está separada de las credenciales gracias a un archivo JSON local en cada proyecto.

---

## 🛠️ Requisitos e Instalación (Windows)

> ℹ️ **Nota sobre el Estado del Proyecto:** Actualmente, la automatización está configurada y optimizada exclusivamente para entornos **Windows**. 

### 1. Guardar el Script de PowerShell
1. Crea una carpeta segura en tu sistema, por ejemplo: `C:\Users\TU_USUARIO\Scripts\`.
2. Guarda el archivo `fetch_schema.ps1` en esa ubicación.

### 2. Configurar la Tarea Global en VS Code
Para que el comando esté disponible en cualquier proyecto que abras, debes registrarlo en tus tareas globales de usuario:

1. Abre la paleta de comandos en VS Code (`Ctrl + Shift + P`).
2. Selecciona **Preferences: Open User Tasks** (*Preferencias: Abrir tareas de usuario*).
3. Reemplaza o añade la siguiente configuración en tu archivo `tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Descargar Esquema DB Global",
      "type": "shell",
      "command": "powershell -ExecutionPolicy Bypass -File C:\\Users\\TU_USUARIO\\Scripts\\fetch_schema.ps1 -workspaceRoot '${workspaceFolder}'",
      "group": "none",
      "presentation": {
        "reveal": "always",
        "panel": "shared"
      }
    }
  ]
}
```

(Asegúrate de cambiar TU_USUARIO por el nombre real de tu perfil de Windows).

## ⚙️ Configuración del Proyecto (`DBConfig.json`)
Para que la tarea sepa a qué servidor y base de datos conectarse, debes crear un archivo llamado DBConfig.json en la raíz de cada proyecto donde desees utilizarlo.

Ejemplo de estructura:
```json
{
  "HOST_url": "tu.servidor.net",
  "HOST_port": 22,
  "HOST_username": "usuario_ssh",
  "HOST_password": "", 
  "DB_username": "admin_db",
  "DB_password": "tu_password_db",
  "DB_database": "nombre_de_tu_base_de_datos",
  "DB_tablesdata": ["tabla_usuarios", "tabla_equipos", "tabla_productos", "tabla_compras"]
}
```

> 🔐 **Tip de Seguridad:** Si dejas `"HOST_password": ""` (vacío), el script asumirá de forma inteligente que tu máquina ya tiene las llaves SSH públicas (`id_rsa.pub`) registradas en el servidor remoto e intentará la conexión directa sin contraseñas.

## 💻 Modo de Uso
Abre cualquier proyecto en VS Code que contenga su respectivo DBConfig.json.

Presiona Ctrl + Shift + P y selecciona Tasks: Run Task (Tareas: Ejecutar tarea).

Elige Descargar Esquema DB Global.

¡Listo! Verás aparecer en tu raíz el archivo estructurado listo para ser indexado por Gemini Code Assist usando @schema_...sql.

🔮 Próximas Mejoras (Roadmap)
* **Detección Automática de S.O.:** El script evolucionará para identificar si se ejecuta en Windows, Linux o macOS, adaptando los comandos de manera interna y transparente.
* **Rutas Genéricas Globales:** Se implementará el uso de variables de entorno del sistema (como `%USERPROFILE%` en Windows) para evitar tener que editar manualmente las rutas absolutas en el archivo `tasks.json`.
