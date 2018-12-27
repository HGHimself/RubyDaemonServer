class Div extends HTMLElement  {
  constructor() {
    // Always call super first in constructor
    super()

    /*
    <div class='width align text-align '>
      <div class='deco'>

      </div>
    </div>
    */


    // Element functionality written in here
    // Create a shadow root
    var shadow = this.attachShadow({mode: 'open'})

    var width = this.getAttribute('width')
    var align = this.getAttribute('align')
    var text_align = this.getAttribute('text_align')

    var wrapper = document.createElement('div')
    wrapper.setAttribute('class', width + " " + align + " " + text_align)

    var deco_div = document.createElement('div')
    deco_div.setAttribute('class','deco')

    deco_div.textContent = this.getAttribute('innerHtml')
    wrapper.appendChild(deco_div)
    // attach the created elements to the shadow dom
    shadow.appendChild(wrapper)
  }

}

window.customElements.define('deco-div', Div)
