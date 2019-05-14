function log(s) { console.log(s); }

var Canvas = (function(){
  let c = document.getElementById("myCanvas");
  let ctx = c.getContext("2d");

  return {
    drawLine: function(x1, y1, x2, y2)  {
      console.log('('+x1+','+y1+')=>('+x2+','+y2+')');
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.stroke();
    },
    color:  function(x)  {
      if (x)  { ctx.strokeStyle = x; }
      return ctx.strokeStyle;
    },
    thickness:  function(t)  {
      if (t)  { ctx.lineWidth = t; }
      return ctx.lineWidth;
    },
    clear:  function()  {
      ctx.clearRect(0, 0, c.width, c.height);
    },
    width: function()  {
      return c.width;
    },
    height: function()  {
      return c.height;
    },
    scaleX: 1,
    scaleY: 1,
    scale:  function(x,y)  {
      console.log('x:'+x+', y:'+y);
      this.scaleX = Number(x);
      this.scaleY = Number(y);
    }
  }
})();

function getnArray(n)  {
  if (!n) return undefined;
  let a = [];
  for (let i = 1; i <= n; ++i)  a.push(i);
  return a;
}

function swap(a, i, j) {
  let h = a[i];
  a[i] = a[j];
  a[j] = h;
}
function shuffle(a)  {
  if(!a) return undefined;
  let j = 0;
  let n = a.length;
  for (let i = 0; i <= n; ++i)  {
    swap(a, i, random(i,n));
  }
  return a;
}

function getRandomNarray(n)  {
  if (!n) return undefined;
  return shuffle(getnArray(n));
}

function random(t, b)  {
  if (!b)  { b = 0; }
  if (!t)  { t = 1; }
  return Math.floor(Math.random() * (t - b) + b);
}

function getColor(i)  {
  let x = Math.round(127 * Math.cos(i  + (3.14159 * 2))) + 128;
  let y = Math.round(127 * Math.sin(i + (3.14159 * 2))) + 128;
  let z = Math.round(127 * Math.cos(i + 3.14159)) + 128;
  return 'rgb('+x+','+y+','+z+')';
}

function bubbleSort(arr)  {
  sorted = [];
  for (let i = 0; i < arr.length; i++)  {
    for (let j = 1; j < arr.length; j++)  {
      if (arr[j - 1] > arr[j])  {
        swap(arr, j - 1, j);
        sorted.push(arr.slice());
      }
    }
  }
  var stop = 0;
  sorted.forEach(function(elem, i){
    window.setTimeout(function()  {
      Canvas.clear();
      for (let i = 0; i < number; i++)  {
        let h = elem[i]
        Canvas.color(getColor(i));
        Canvas.drawLine((width-elem[i]),height-(i/2),(width-elem[i]),(i/2));
      }
    }, 500*i);
  });
}

let number  = 25;
let arr     = getRandomNarray(number);

let width   = Canvas.width();
let height  = Canvas.height();

Canvas.scale(width/number,height/number);
Canvas.thickness(5);

bubbleSort(arr);
