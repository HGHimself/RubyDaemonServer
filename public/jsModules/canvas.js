
var Canvas = ( function() {

  let c = document.getElementById( "myCanvas" );
  let ctx = c.getContext( "2d" );
  let container = $( "#canvasContainer" );

  let scaleX = 1;
  let scaleY = 1;

  let multiplier = 1;
  let offset = 0;
  let callback;

  /*  Hope you can do this here, I think so because it is not really a class  */
  $( document ).ready( function() {
    $( window ).resize( function() {
      init();
    });
  });

  function init( c )  {
    if ( c ) { callback = c; }
    if ( callback )  { callback(); }
    console.log( 'This does indeed work' );
  }

  function clear()  {
    ctx.clearRect( 0, 0, c.width, c.height );
  }

  function setScale( x, y )  {
    scaleX = x;
    scaleY = y;
  }

  function setLineScale( length )  {
    scaleX = c.width/length;
    scaleY = c.height/length;

    ctx.lineWidth = scaleX;
  }

  function drawLine( x1, y1, x2, y2 )  {

    x1 *= scaleX;
    x2 *= scaleX;
    y1 *= scaleY;
    y2 *= scaleY;

    //log(x1+","+y1+"=>"+x2+","+y2);
    ctx.beginPath();
    ctx.moveTo( x1, y1 );
    ctx.lineTo( x2, y2 );
    ctx.stroke();
  }

  function setColor( x )  {
    if ( x )  { ctx.strokeStyle = x; }
    return ctx.strokeStyle;
  }

  return {
    init: init,
    drawLine: drawLine,
    setColor:  setColor,
    setScale: setScale,
    setLineScale: setLineScale,
    clear:  clear,
    c: c,
    $container: container,
  }
})();
