
( () => {
    let sorts = {
      'Bubble'    : 0,
      'Gnome'     : 1,
      'Cocktail'  : 2,
      'Pancake'   : 3,
      'Insertion' : 4,
    };

    let lengths = {
      10 : 10,
      25 : 25,
      50 : 50,
      75 : 75,
      100:100,
    };

    let options = {
      'sorts'   : sorts,
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

    $( document ).ready(() => {
      console.log(Canvas.$container.innerWidth());
      Canvas.init( () => {
        console.log(Canvas.$container.innerWidth());
        Canvas.c.width  = 0.80 * Canvas.$container.innerWidth();
        //Canvas.c.height = Canvas.$container.innerHeight();
      });
    });

})();

function doSort()  {
  Slug.start();
}

function stopSort()  {
  Slug.stop();
}
