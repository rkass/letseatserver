var timeout;
function open_appstore(auth_token) {
  alert("openappstore");
  window.location='letsEat://register/' + auth_token
}

function try_to_open_app(auth_token) {
  alert("try to open app");
  timeout = setTimeout('open_appstore(auth_token)', 300);
}

function helloWorld(){
  alert("Hello World!");
}
