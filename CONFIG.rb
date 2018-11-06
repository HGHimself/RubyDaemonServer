#-Do your configuring here boys-#

PORT       = 12345

HOST       = "0.0.0.0"

STATUS_CODES = {
  200 => 'OK',
  500 => 'Internal Server Error',
  404 => 'Not Found'
}

HAS_BODY = ["POST", "PUT", "PATCH"]

# Files will be served from this directory
WEB_ROOT = './public'
LOG_FILE = './log/log.txt'
PID_FILE = './pid.txt'

SERVER_ERR_PAGE = 'error/50X.html'
NOT_FOUND_PAGE = 'error/404.html'


# Map extensions to their content type
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt'  => 'text/plain',
  'zip'  => 'applicaiton/zip',
  'png'  => 'image/png',
  'jpg'  => 'image/jpeg',
  'cgi'  => 'script/cgi',
  'rb'  => 'script/rb'
}

# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'
