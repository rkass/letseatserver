var timeout;
function open_appstore(auth_token) {
  window.location='letsEat://' + 'register/' + auth_token;
}

function try_to_open_app(auth_token) {
  timeout = setTimeout('open_appstore(auth_token)', 300);
}

function helloWorld(){
  alert("Hello World!");
}
