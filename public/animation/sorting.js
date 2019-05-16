var Canvas = (function(){

  let c = document.getElementById("myCanvas");
  let ctx = c.getContext("2d");
  let arr = [];
  let length = 25;
  let interval = 30;
  let callstack = [];
  let intervalId = 0;
  let scaleX = 1;
  let scaleY = 1;

  function init()  {
    if(intervalId == 0)  {
      scaleX = c.width/length;
      scaleY = c.height/length;

      ctx.lineWidth = scaleX;

      for (let i = 1; i <= length; ++i)  arr.push(i);

      shuffle();
      bubbleSort();
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
    if(top) while(--top) {
      current = Math.floor(Math.random() * (top + 1));
      swap(current,top);
    }
  }

  function random(t, b)  {
    if (!b)  { b = 0; }
    if (!t)  { t = 1; }
    return Math.floor(Math.random() * (t - b) + b);
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

  function drawLine(x1, y1, x2, y2)  {
    x1 *= scaleX;
    x2 *= scaleX;
    y1 *= scaleY;
    y2 *= scaleY;
    //log(x1+","+y1+"=>"+x2+","+y2);
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

  function run()  {
    intervalId = setInterval(function() {
      if(callstack.length == 0)  {
        Canvas.stop();
        Canvas.init();
      } else {
        let elem = callstack.shift();
        let number = elem.length;
        if(elem)  {
          Canvas.clear();
          for (let i = 0; i < number; i++)  {
            let val = elem[i];
            Canvas.color(getColor(val, number));
            Canvas.drawLine(i,(number-val)/2,i,(number-val)/2+val);
          }
        }
      }
    }, interval);
  }

  function stop()  {
    clearInterval(intervalId);
    intervalId = 0;
    callstack = [];
    arr = [];
    clear();
  }

  function getColor(i, n)  {
    let phi = (i/n)*3.14* 1.3;
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
    run: run,
    stop: stop,
  }
})();

function doSort()  {
  Canvas.init();
}

function stopSort()  {
  Canvas.stop();
}
