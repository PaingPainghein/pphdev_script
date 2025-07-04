<?php
// Conexión SSH con autenticación mediante la extensión SSH2 de PHP

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get server IP from environment variable or configuration file
$server_ip = getenv('PPHDEV_SERVER_IP') ?: '127.0.0.1'; // Default to localhost if not set

// Verifica si se ha proporcionado el parámetro 'token' en la URL
if (isset($_GET['token'])) {
    $username = $_GET['token']; // Obtiene el valor del parámetro 'token' de la URL
    $conexion = ssh2_connect($server_ip, 22); // Usa la IP del servidor y el puerto 22
    if (!$conexion) {
        die('La conexión SSH falló.');
    }

    $auth = ssh2_auth_password($conexion, $username, 'DEXVPN'); // Ingresa la contraseña
    if (!$auth) {
        echo 'Fail'; // Si la autenticación falla
    } else {
        echo 'OK'; // Si la autenticación es exitosa
    }
} else {
    echo 'No hay nada que ver aquí.'; // Mensaje si no se proporciona el parámetro 'token'
}
?>
