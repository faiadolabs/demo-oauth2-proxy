import logging
import signal
import sys
import threading
import time
import requests
import webbrowser
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs

# Configurar logging
logging.basicConfig(filename='app.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Configuración
keycloak_url = 'http://localhost:8080'
realm = 'master'
client_id = 'pyscript'
client_secret = 'nggfjJy6jZtaviXphccPfe7eZZSHm1D0'
redirect_uri = 'http://localhost:5000/callback'

# URL de autorización y token
auth_url = f'{keycloak_url}/realms/{realm}/protocol/openid-connect/auth'
token_url = f'{keycloak_url}/realms/{realm}/protocol/openid-connect/token'

# Crear la URL de autorización
auth_params = {
    'response_type': 'code',
    'client_id': client_id,
    'redirect_uri': redirect_uri,
    'scope': 'openid profile email'
}

# Bandera para indicar la detención del servidor
stop_server = threading.Event()

# Definir el manejador de la señal
def signal_handler(sig, frame):
    logging('\nSe ha detectado Ctrl+C! Terminando el servidor...')
    stop_server.set()
    sys.exit(0)

# Asociar la señal SIGINT con el manejador
signal.signal(signal.SIGINT, signal_handler)

auth_request_url = requests.Request('GET', auth_url, params=auth_params).prepare().url
print("Petición inicial de autorización: ", auth_request_url)

# Manejador del HTTPServer para recibir el código de autorización
class CallbackHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Sobrescribir para evitar imprimir los mensajes de log en la consola
        pass

    def do_GET(self):
        if self.path.startswith('/callback'):
            # Parseo la información que me llega al callback
            try:
                query_components = parse_qs(self.path.split('?')[1])
            except Exception as e:
                print(f"Error al parsear la URL: {e}")
                return
            
            code = query_components.get('code', [None])[0]
            if not code:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'No code parameter in the callback request')
                return

            # Intercambiar el código por un token de acceso
            data = {
                'grant_type': 'authorization_code',
                'client_id': client_id,
                'client_secret': client_secret,
                'code': code,
                'redirect_uri': redirect_uri
            }

            response = requests.post(token_url, data=data)
            if response.status_code != 200:
                self.send_response(response.status_code)
                self.end_headers()
                self.wfile.write(response.text.encode())
                return

            token_response = response.json()
            access_token = token_response.get('access_token')
            if not access_token:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'No se pudo obtener el token de acceso.')
                return
            
            print("\n🔑 Obtenido correctamente un token válido de sesión! Recuperando info de usuario...")

            # Usar el token para acceder al recurso protegido
            protected_url = f'{keycloak_url}/realms/{realm}/protocol/openid-connect/userinfo'
            headers = {
                'Authorization': f'Bearer {access_token}'
            }

            response = requests.get(protected_url, headers=headers)
            if response.status_code != 200:
                self.send_response(response.status_code)
                self.end_headers()
                self.wfile.write(response.text.encode())
                return

            user_info = response.json()
            user_info_json = json.dumps(user_info, indent=4)
            
            # Mostrar la información del usuario en la consola
            print('\n ✅ User Info:', user_info_json)

            # Responder con un mensaje de éxito
            success_message = '''
                <html>
                <head><title>Autenticación Exitosa</title></head>
                <body>
                    <h1>Autenticación exitosa</h1>
                    <p>Vuelve a la CLI Application para obtener la información del usuario.</p>
                    <p>Puedes cerrar esta pestaña de tu navegador!</p>
                </body>
                </html>
            '''
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(success_message.encode('utf-8'))
            # Ya no tengo que seguir esperando el callback
            stop_server.set()

# Función para preguntar al usuario si desea abrir el navegador
def ask_to_open_browser():
    answer = input('\n¿Deseas abrir el navegador para la autenticación? (s/n): ')
    if answer == 's':
        webbrowser.open(auth_request_url)
    else: print("Pues pulsa el enlace para continuar...")

# Función para ejecutar el servidor HTTP y esperar el callback
def wait_for_callback():
    server_address = ('', 5000)
    httpd = HTTPServer(server_address, CallbackHandler)
    print('\nEsperando el callback de Keycloak...')
    
    while not stop_server.is_set():
        httpd.handle_request()

    httpd.server_close()
    print('\nAutenticación y Autorización Existosa!\n')

# Mensaje adviertiendo al usuario de que clice en el siguiente enlace (auth_request_url)
print('\n\n 👉 Por favor, haz clic en el siguiente enlace para autenticarte:')
print(f"\n {auth_request_url}")

# Iniciar el thread para esperar el callback
callback_thread = threading.Thread(target=wait_for_callback)
callback_thread.start()

# Preguntar al usuario si desea abrir el navegador
# Esto se ejecuta en el hilo principal
time.sleep(1); # Hago un pequeño delay para que el mensaje anterior se muestre antes de preguntar
ask_to_open_browser()

# Esperar a que el thread del callback termine
callback_thread.join()
print("Servidor detenido correctamente. Fin de la demo! 👋 \n")
