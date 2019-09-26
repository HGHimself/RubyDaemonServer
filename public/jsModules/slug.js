
var Slug = ( () => {

  let arr = [];
  let length = 20;
  let interval = 25;
  let callstack = [];
  let intervalId = 0;

  let state = 0;

  function start()  {
    state++;
    init();
  }

  function init()  {
    if ( !intervalId && state )  {

      length = document.getElementById( 'lengths' ).value;
      Canvas.setLineScale( length );

      for ( let i = 1; i <= length; ++i )  { arr.push( i ); }

      shuffle();
      let r = document.getElementById( 'sorts' ).value;

      if ( r  == 0 )  {
        bubbleSort();
      } else if ( r == 1 ) {
        gnomeSort();
      } else if ( r == 2 ) {
        cocktailSort();
      } else if ( r == 3 ) {
        pancakeSort();
      } else if ( r == 5 ) {
        pancakeSort();
      } else if ( r == 4 ){
        insertionSort();
      }

      document.getElementById( 'steps' ).innerHTML = callstack.length + ' steps';
      run();
    }
  }

  function swap(i, j) {
    let h = arr[i];
    arr[i] = arr[j];
    arr[j] = h;
  }

  function shuffle() {
    let tmp, current, top = length;
    if ( top ) while( --top ) {
      current = Math.floor( Math.random() * ( top + 1 ) );
      swap( current, top );
    }
  }

  function random( t, b )  {
    if ( !b )  { b = 0; }
    if ( !t )  { t = 1; }
    return Math.floor( Math.random() * ( t - b ) + b );
  }

  function merge(arr, start, mid, end)   {
    let start2 = mid + 1;
    if (arr[mid] <= arr[start2]) { return;  }
    while (start <= mid && start2 <= end) {
      if (arr[start] <= arr[start2]) { start++; }
      else {
        let value = arr[start2];
        let index = start2;
        while (index != start) {
          arr[index] = arr[index - 1];
          index--;
          callstack.push(arr.slice());
        }
        arr[start] = value;
        start++;
        mid++;
        start2++;
        callstack.push(arr.slice());
      }
    }
  }

  function mergeSort(arr, l, r)  {
    if (l < r)  {
      log('recurring');
      let m = l + (r - l) / 2;
      mergeSort(arr, l, m);
      mergeSort(arr, m + 1, r);
      merge(arr, l, m, r);
    }
  }

  function bubbleSort()  {
    for (let i = 0; i < length; i++)  {
      for (let j = 1; j < length; j++)  {
        if (arr[j - 1] > arr[j])  {
          swap(j - 1, j);
          callstack.push(arr.slice());
        }
      }
    }
  }

  function insertionSort()  {
    let i = j = key = 0;
    for (i = 1; i < length; i++)  {
      key = arr[i];
      j = i - 1;
      while (j >= 0 && arr[j] > key) {
          arr[j + 1] = arr[j];
          j = j - 1;
          callstack.push(arr.slice());
      }
      arr[j + 1] = key;
      callstack.push(arr.slice());
    }
  }

  function gnomeSort()  {
    let index = 0;
    while (index < length) {
        if (index == 0)
            index++;
        if (arr[index] >= arr[index - 1])
            index++;
        else {
            swap(index, index - 1);
            callstack.push(arr.slice());
            index--;
        }
    }
  }

  function cocktailSort()  {
    let start = -1;
    let end = length - 2;
    let swapped;
    let i;

    do {
      swapped = false;
      for (i = ++start; i <= end; i++) {
        if (arr[i] > arr[i+1]) {
          swap(i, i + 1);
          callstack.push(arr.slice());
          swapped = true;
        }
      }

      if (!swapped) {
        break;
      }

      swapped = false;
      for (i = --end; i >= start; i--) {
        if (arr[i] > arr[i+1]) {
          swap(i, i + 1);
          callstack.push(arr.slice());
          swapped = true;
        }
      }
    } while (swapped);

  }

  function flip(i)  {
    let temp, start = 0;
    while (start < i)  {
      swap(start, i);
      callstack.push(arr.slice());
      start++;
      i--;
    }
  }

  function findMax(n)  {
    let mi = 0;
    for (let i = 0; i < n; ++i)
      if (arr[i] > arr[mi])
        mi = i;
    return mi;
  }

  function pancakeSort()  {
    for (let curr_size = length; curr_size > 1; --curr_size)  {
      let mi = findMax(curr_size);
      if (mi != curr_size-1)  {
        flip(mi);
        flip(curr_size-1);
      }
    }
  }

  function run()  {
    let interval_val = document.getElementById('interval').value;
    intervalId = setInterval( () => {
      if (callstack.length == 0 || state == 0 )  {
        Slug.reset();
        Slug.init();
      } else {

        let elem = callstack.shift();
        let number = elem.length;
        if ( elem )  {
          let offset = document.getElementById('offset').value;
          let multiple = document.getElementById('multiplier').value;
          Chromata.setColorValues( multiple, offset );
          Canvas.clear();
          for (let i = 0; i < number; i++)  {
            let val = elem[i];
            let color = Chromata.getColor(val, number);
            let triangle = ( number - val ) / 2;

            Canvas.setColor( color );
            Canvas.drawLine( i, triangle, i, triangle + val );
          }
        }

      }
    }, interval_val );
  }

  function reset()  {
    clearInterval( intervalId );
    intervalId = 0;
    callstack = [];
    arr = [];
    //Canvas.clear();
  }

  function stop()  {
    state = 0;
  }

  return {
    start: start,
    init: init,
    run: run,
    reset: reset,
    stop: stop,
  }
})();
