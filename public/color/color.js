(function () {

    let lengths = {
      10 : 10,
      25 : 25,
      47 : 47,
      50 : 50,
      75 : 75,
      100:100,
      180:180,
      300:300,
      1000:1000,
    };

    let options = {
      'lengths' : lengths,
    };

    for ( let i in options ) {
      let select = document.getElementById( i );

      for ( let j in options[i] ) {
        let option = document.createElement( "option" );
        option.text = j;
        option.value = options[i][j];
        select.add(option);
      };

    };


})();

var Canvas = (function(){

  let c = document.getElementById("myCanvas");
  let ctx = c.getContext("2d");
  let callstack = [];
  let length = 100;
  scaleX = c.width/length;
  scaleY = c.height/length;
  ctx.lineWidth = c.width / length;

  function init( )  {
    length = document.getElementById('lengths').value;
    scaleX = c.width/length;
    scaleY = c.height/length;
    ctx.lineWidth = c.width / length;
    Canvas.clear();
    for ( let i = 0; i < length; i++ )  {
      for ( let j = 0; j < length; j++ )  {
        Canvas.color(getColor(i, j));
        Canvas.drawLine(i,j,i+1,j);
      }
    }
  }

  function drawLine(x1, y1, x2, y2)  {
    x1 *= scaleX;
    x2 *= scaleX;
    y1 *= scaleY;
    y2 *= scaleY;
    console.log(x1+","+y1+"=>"+x2+","+y2);
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
  }

  function color(x)  {
    if (x)  { ctx.strokeStyle = x; }
    return ctx.strokeStyle;
  }

  function clear()  {
    ctx.clearRect(0, 0, c.width, c.height);
  }

  function getColor(i, n)  {
    let multiplier = document.getElementById('colors').value;
    let offset = document.getElementById('offset').value;
    let phi = ((i/n) + offset) * multiplier * 10;
    let x = Math.round(127 * Math.cos(phi + (3.14159 * 2))) + 128;
    let y = Math.round(127 * Math.sin(phi + (3.14159 * 2))) + 128;
    let z = Math.round(127 * Math.cos(phi + 3.14159)) + 128;
    return 'rgb('+x+','+y+','+z+')';
  }

  return {
    init: init,
    drawLine: drawLine,
    color:  color,
    clear:  clear,
  }
})();

function draw()  {
  Canvas.init();
}
