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
PID_FILE = './log/pid.txt'

SERVER_ERR_PAGE = 'error/50X.html'
NOT_FOUND_PAGE = 'error/404.html'


# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'

# Map extensions to their content type
CONTENT_TYPE_MAPPING = {
  'bin'   => DEFAULT_CONTENT_TYPE,
  'json'  => 'application/json',
  'zip'   => 'applicaiton/zip',
  'midi'  => 'audio/midi',
  'gif'   => 'image/gif',
  'jpg'   => 'image/jpeg',
  'jpeg'  => 'image/jpeg',
  'png'   => 'image/png',
  'cgi'   => 'script/cgi',
  'rb'    => 'script/rb',
  'css'   => 'text/css',
  'csv'   => 'text/csv',
  'html'  => 'text/html',
  'majin' => 'text/html',
  'js'    => 'text/javascript',
  'txt'   => 'text/plain'
}

REQUEST_TYPE_MAPPING = {
  'application/x-www-form-urlencoded' => 'form encoded',
  'text/plain' => 'plain text'
}
