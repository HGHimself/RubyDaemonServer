class Footer extends HTMLElement  {
  constructor() {
    // Always call super first in constructor
    super()

    /*
    <footer>
      <p class="footer-text">
      <a href="about.php">About</a> &#124
      <a href="contact.php">Contact Us</a> &#124
      Copyright &copy <time datetime="2018">2018</time>
      </p>
    </footer>
    */

    // Element functionality written in here
    // Create a shadow root
    var shadow = this.attachShadow({mode: 'open'})

    // Create spans
    var footer = document.createElement('footer')
    footer.setAttribute('class', 'deco')
    
    var p = document.createElement('p')
    p.setAttribute('class','footer-text')

    var about = document.createElement('a')
    about.setAttribute('href','about.html')
    about.textContent = 'About'

    var contact = document.createElement('a')
    contact.setAttribute('href','contact.html')
    contact.textContent = 'Contact Us'

    p.appendChild(about)
    p.appendChild(contact)
    footer.appendChild(p)
    // attach the created elements to the shadow dom
    shadow.appendChild(footer)
  }

}

window.customElements.define('deco-footer', Footer)
