
var Chromata = ( () => {

  let multiplier = 1;
  let offset = 0;

  function getColor( i, n )  {
    let phi = ( ( i / n ) + offset ) * multiplier * 10;
    let x = Math.round(127 * Math.cos(phi + (3.14159 * 2))) + 128;
    let y = Math.round(127 * Math.sin(phi + (3.14159 * 2))) + 128;
    let z = Math.round(127 * Math.cos(phi + 3.14159)) + 128;
    return 'rgb('+x+','+y+','+z+')';
  }

  function setColorValues( m, o )
  {
    multiplier = m;
    offset = o;
  }

  return {
    getColor: getColor,
    setColorValues, setColorValues,
  };

})();
