# Recibir la ruta del proyecto actual como parámetro desde VS Code
param (
    [string]$workspaceRoot
)

if ([string]::IsNullOrEmpty($workspaceRoot)) {
    Write-Error "No se proporcionó la ruta del proyecto (workspaceRoot)."
    exit 1
}

# 1. Leer y decodificar el archivo JSON de configuración en la raíz del proyecto abierto
$configPath = Join-Path $workspaceRoot "DBConfig.json"
if (-not (Test-Path $configPath)) {
    Write-Error "No se encontró el archivo DBConfig.json en la raíz del proyecto actual ($workspaceRoot)."
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# 2. Generar la fecha y hora actual para el nombre del archivo
# Formato resultante: schema_2026-06-06_21-15.sql (Año-Mes-Día_Hora-Minuto)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$DB_database = $config.DB_database
$fileName = "schema_${DB_database}_${timestamp}.sql"
$outputPath = Join-Path $workspaceRoot $fileName

# 3. Preparar los fragmentos del comando de MySQL
$mysqlPart = "mysqldump -u $($config.DB_username) -p`"$($config.DB_password)`" --no-data $($config.DB_database)"

# Si existen tablas marcadas para incluir datos, añadimos el comando para extraer solo los INSERTs
if ($null -ne $config.DB_tablesdata -and $config.DB_tablesdata.Count -gt 0) {
    $tables = $config.DB_tablesdata -join " "
    $mysqlPart += " && mysqldump -u $($config.DB_username) -p`"$($config.DB_password)`" --no-create-info $($config.DB_database) $tables"
}

# 4. Evaluar e intentar la ejecución capturando errores
if ([string]::IsNullOrEmpty($config.HOST_password)) {
    Write-Host "Conectando mediante llave SSH pública a $($config.HOST_url):$($config.HOST_port)..."
    $resultado = ssh -p $config.HOST_port -o ConnectTimeout=5 "$($config.HOST_username)@$($config.HOST_url)" $mysqlPart 2>&1
} else {
    Write-Host "Conectando mediante contraseña SSH..."
    $resultado = sshpass -p $config.HOST_password ssh -p $config.HOST_port "$($config.HOST_username)@$($config.HOST_url)" $mysqlPart 2>&1
}

# 5. Validar el resultado antes de escribir el archivo
if ($resultado -match "error" -or $resultado -match "Permission denied" -or [string]::IsNullOrEmpty($resultado)) {
    Write-Host "❌ Error detectado en la conexión o en el volcado de la DB:" -ForegroundColor Red
    Write-Host $resultado -ForegroundColor Yellow
} else {
    # Guardamos el archivo con el nuevo nombre dinámico
    $resultado | Out-File -FilePath $outputPath -Encoding utf8
    Write-Host "¡Esquema de base de datos actualizado con éxito en: $fileName!" -ForegroundColor Green
}
