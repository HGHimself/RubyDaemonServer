
var state = "initial"

function keygen()  {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById("keys_landing").innerHTML = this.responseText;
    }
  };
  document.getElementById("keys_landing").innerHTML = "Generating keys..."
  p = document.getElementById("p").value
  q = document.getElementById("q").value
  xhttp.open("GET", "/encryption/keygen/?p=" + p + "&q=" + q, true);
  xhttp.send();
  state = "keys"
}

function encrypt()  {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById("encrypt_landing").innerHTML = this.responseText;
    }
  };
  document.getElementById("encrypt_landing").innerHTML = "Encrypting..."
  p = document.getElementById("p").value
  q = document.getElementById("q").value
  m = document.getElementById("m").value
  xhttp.open("GET", "/encryption/encrypt/?m=" + m + "&p=" + p + "&q=" + q, true);
  xhttp.send();
  state = "encrypted"
}

function decrypt()  {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById("decrypt_landing").innerHTML = this.responseText;
    }
  };
  document.getElementById("decrypt_landing").innerHTML = "Decrypting..."
  p = document.getElementById("p").value
  q = document.getElementById("q").value
  m = document.getElementById("m").value
  xhttp.open("GET", "/encryption/decrypt/?m=" + m + "&p=" + p + "&q=" + q, true);
  xhttp.send();
  state = "decrypted"
}
