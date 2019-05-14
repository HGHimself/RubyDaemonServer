
$(function() {
  doGraph('graph-type');
});

var Grapher = (function ()  {

  let graph;
  let state = 0;
  let $elem = $('#data-usage');

  function getData(path)  {
    return $.parseJSON($.ajax({
      url:  path,
      dataType: "json",
      async: false
    }).responseText);
  }

  function graphInit()  {
    if(!state)  {
      graph = echarts.init(document.getElementById('data-usage'), theme);
      state = 1;
    }
  }

  let makeGraph = function(type, option)  {
    graphInit();
    let data
    if(type == 'req-res')  {
      data = getData('/performance/data.json?param=0');
      for (let key in data) {
        let newData = []
        data[key].forEach(function(val)  {
          newData.push([val[2],val[3],val[0],val[4],val[1]]);
        });
        option.series.push({
          name: key,
          symbolSize: function (value){
            return Math.log(value[3]) * 2;
          },
          type: 'scatter',
          data: newData
        });
        option.legend.data.push(key);
      }
    } else if(type == 'ip-bar')  {
      data = getData('/performance/data.json?param=1');
      let newData = {
        name: 'Access',
        type: 'bar',
        data: [],
        animationDelay: function (idx) {
            return idx * 10;
        }
      };
      for (let key in data) {
        newData.data.push(data[key].length);
        option.yAxis.data.push(key);
      }
      option.series.push(newData);
    } else if(type == 'byte-res')  {
      data = getData('/performance/data.json?param=0');
      for (let key in data) {
        let newData = []
        data[key].forEach(function(val)  {
          newData.push([Math.log(val[4]) * 2,val[2],val[0],val[4],val[1]]);
        });
        option.series.push({
          name: key,
          symbolSize: function (value){
            return value[0];
          },
          type: 'scatter',
          data: newData
        });
        option.legend.data.push(key);
      }
    }

    graph.setOption(option, true), $(function () {
        function resize() {
            setTimeout(function () {
                graph.resize()
            }, 100)
        }
        $(window).on("resize", resize);
    });
  };

  let clearGraph = function()  {
    if(state) {
      echarts.dispose(graph);
      state = 0;
    }
  };

  let theme = {
    backgroundColor: '#F2F2F6',
    // 默认色板
    color: [
        '#44B7D3','#E42B6D','#F4E24E','#FE9616','#8AED35',
        '#ff69b4','#ba55d3','#cd5c5c','#ffa500','#40e0d0',
        '#E95569','#ff6347','#7b68ee','#00fa9a','#ffd700',
        '#6699FF','#ff6666','#3cb371','#b8860b','#30e0e0'
    ],

    // 图表标题
    title: {
        x:'center',
        y:'top',
        backgroundColor: '#F2F2F6',
        itemGap: 10,               // 主副标题纵向间隔，单位px，默认为10，
        textStyle: {
            color: '#212529'          // 主标题文字颜色
        },
        subtextStyle: {
            color: '#E877A3'          // 副标题文字颜色
        }
    },

    // 值域
    dataRange: {
        x:'right',
        y:'center',
        itemWidth: 5,
        itemHeight:25,
        color:['#E42B6D','#F9AD96'],
        text:['高','低'],         // 文本，默认为数值文本
        textStyle: {
            color: '#8A826D'          // 值域文字颜色
        }
    },

    toolbox: {
        color : ['#E95569','#E95569','#E95569','#E95569'],
        effectiveColor : '#ff4500',
        itemGap: 8
    },

    // 提示框
    tooltip: {
        backgroundColor: 'rgba(138,130,109,0.7)',     // 提示背景颜色，默认为透明度为0.7的黑色
        axisPointer : {            // 坐标轴指示器，坐标轴触发有效
            type : 'line',         // 默认为直线，可选为：'line' | 'shadow'
            lineStyle : {          // 直线指示器样式设置
                color: '#6B6455',
                type: 'dashed'
            },
            crossStyle: {          //十字准星指示器
                color: '#A6A299'
            },
            shadowStyle : {                     // 阴影指示器样式设置
                color: 'rgba(200,200,200,0.3)'
            }
        }
    },


    // 区域缩放控制器
    dataZoom: {
        dataBackgroundColor: 'rgba(130,197,209,0.6)',            // 数据背景颜色
        fillerColor: 'rgba(233,84,105,0.1)',   // 填充颜色
        handleColor: 'rgba(107,99,84,0.8)'     // 手柄颜色
    },

    grid: {
      x: 80,
      y: 60,
      x2: 80,
      y2: 60,
      // width: {totalWidth} - x - x2,
      // height: {totalHeight} - y - y2,
      backgroundColor: 'rgba(0,0,0,0)',
      borderWidth: 1,
      borderColor: '#ccc'
    },

    legend: {
       orient: 'vertical',
       x: 'right',
       y: 'center',
       backgroundColor: 'rgba(0,0,0,0)',
       borderColor: '#ccc',
       borderWidth: 0,
       padding: 5,
       itemGap: 10,
       itemWidth: 20,
       itemHeight: 14,
       textStyle: {
         color: '#333'
       }
     },

    // 类目轴
    categoryAxis: {
        axisLine: {            // 坐标轴线
            lineStyle: {       // 属性lineStyle控制线条样式
                color: '#6B6455'
            }
        },
        splitLine: {           // 分隔线
            show: false
        }
    },

    // 数值型坐标轴默认参数
    valueAxis: {
        axisLine: {            // 坐标轴线
            show: false
        },
        splitArea : {
            show: false
        },
        splitLine: {           // 分隔线
            lineStyle: {       // 属性lineStyle（详见lineStyle）控制线条样式
                color: ['#FFF'],
                type: 'dashed'
            }
        }
    },

    polar : {
        axisLine: {            // 坐标轴线
            lineStyle: {       // 属性lineStyle控制线条样式
                color: '#ddd'
            }
        },
        splitArea : {
            show : true,
            areaStyle : {
                color: ['rgba(250,250,250,0.2)','rgba(200,200,200,0.2)']
            }
        },
        splitLine : {
            lineStyle : {
                color : '#ddd'
            }
        }
    },

    timeline : {
        lineStyle : {
            color : '#6B6455'
        },
        controlStyle : {
            normal : { color : '#6B6455'},
            emphasis : { color : '#6B6455'}
        },
        symbol : 'emptyCircle',
        symbolSize : 3
    },

    // 柱形图默认参数
    bar: {
        itemStyle: {
            normal: {
                barBorderRadius: 0
            },
            emphasis: {
                barBorderRadius: 0
            }
        }
    },

    // 折线图默认参数
    line: {
        smooth : true,
        symbol: 'emptyCircle',  // 拐点图形类型
        symbolSize: 3           // 拐点图形大小
    },


    // K线图默认参数
    k: {
        itemStyle: {
            normal: {
                color: '#E42B6D',       // 阳线填充颜色
                color0: '#44B7D3',      // 阴线填充颜色
                lineStyle: {
                    width: 1,
                    color: '#E42B6D',   // 阳线边框颜色
                    color0: '#44B7D3'   // 阴线边框颜色
                }
            }
        }
    },

    // 散点图默认参数
    scatter: {
        itemStyle: {
            normal: {
                borderWidth:1,
                borderColor:'rgba(200,200,200,0.5)'
            },
            emphasis: {
                borderWidth:0
            }
        },
        symbol: 'circle',    // 图形类型
        symbolSize: 4        // 图形大小，半宽（半径）参数，当图形为方向或菱形则总宽度为symbolSize * 2
    },

    // 雷达图默认参数
    radar : {
        symbol: 'emptyCircle',    // 图形类型
        symbolSize:3
        //symbol: null,         // 拐点图形类型
        //symbolRotate : null,  // 图形旋转控制
    },

    map: {
        itemStyle: {
            normal: {
                areaStyle: {
                    color: '#ddd'
                },
                label: {
                    textStyle: {
                        color: '#E42B6D'
                    }
                }
            },
            emphasis: {                 // 也是选中样式
                areaStyle: {
                    color: '#fe994e'
                },
                label: {
                    textStyle: {
                        color: 'rgb(100,0,0)'
                    }
                }
            }
        }
    },

    force : {
        itemStyle: {
            normal: {
                nodeStyle : {
                    borderColor : 'rgba(0,0,0,0)'
                },
                linkStyle : {
                    color : '#6B6455'
                }
            }
        }
    },

    chord : {
        itemStyle : {
            normal : {
                chordStyle : {
                    lineStyle : {
                        width : 0,
                        color : 'rgba(128, 128, 128, 0.5)'
                    }
                }
            },
            emphasis : {
                chordStyle : {
                    lineStyle : {
                        width : 1,
                        color : 'rgba(128, 128, 128, 0.5)'
                    }
                }
            }
        }
    },

    gauge : {                  // 仪表盘
        center:['50%','80%'],
        radius:'100%',
        startAngle: 180,
        endAngle : 0,
        axisLine: {            // 坐标轴线
            show: true,        // 默认显示，属性show控制显示与否
            lineStyle: {       // 属性lineStyle控制线条样式
                color: [[0.2, '#44B7D3'],[0.8, '#6B6455'],[1, '#E42B6D']],
                width: '40%'
            }
        },
        axisTick: {            // 坐标轴小标记
            splitNumber: 2,   // 每份split细分多少段
            length: 5,        // 属性length控制线长
            lineStyle: {       // 属性lineStyle控制线条样式
                color: '#fff'
            }
        },
        axisLabel: {           // 坐标轴文本标签，详见axis.axisLabel
            textStyle: {       // 其余属性默认使用全局文本样式，详见TEXTSTYLE
                color: '#fff',
                fontWeight:'bolder'
            }
        },
        splitLine: {           // 分隔线
            length: '5%',         // 属性length控制线长
            lineStyle: {       // 属性lineStyle（详见lineStyle）控制线条样式
                color: '#fff'
            }
        },
        pointer : {
            width : '40%',
            length: '80%',
            color: '#fff'
        },
        title : {
          offsetCenter: [0, -20],       // x, y，单位px
          textStyle: {       // 其余属性默认使用全局文本样式，详见TEXTSTYLE
            color: 'auto',
            fontSize: 20
          }
        },
        detail : {
            offsetCenter: [0, 0],       // x, y，单位px
            textStyle: {       // 其余属性默认使用全局文本样式，详见TEXTSTYLE
                color: 'auto',
                fontSize: 40
            }
        }
    },

    textStyle: {
        fontFamily: '微软雅黑, Arial, Verdana, sans-serif'
    }
  };

  return {
    graph: graph,
    graphInit: graphInit,
    makeGraph: makeGraph,
    clearGraph: clearGraph
  };

})();

function doGraph(select_id)  {
  clearGraph();
  const type = $('#'+select_id).val();
  if(type == 'req-res')  {
    option = {
      title : {
         text : 'General Server Performance',
         subtext : ''
      },
      tooltip : {
         trigger: 'item',
         formatter : function (params) {
             data = 'Filename: '+params.value[3]+'<br/>';
             data+= 'Bytes: '+params.value[5]+'<br/>';
             data+= 'IP: '+params.value[4]+'<br/>';
             data+= 'Response, Request: '+params.value[0]+', '+params.value[1];
             return data;
         }
      },
      toolbox: {
        feature: {
            dataZoom: {}
        }
      },
      xAxis: {
          type: 'value',
          name: 'Request Time(ms)',
          nameGap: 16,
          nameTextStyle: {
              fontSize: 14
          },
          splitLine: {
              show: false
          },
      },
      yAxis: {
          type: 'value',
          name: 'Response Time(ms)',
          nameLocation: 'end',
          nameGap: 20,
          nameTextStyle: {
              fontSize: 16
          },
          splitLine: {
              show: false
          }
      },
      dataZoom: [{
          type: 'inside'
      }, {
          type: 'slider'
      }],

      series: [],

      legend: {
        data: [],
      }
    };
  } else if(type == 'ip-bar')  {
    option = {
      title: {
          text: 'General Server Performance'
      },
      legend: {
          data: ['IP Addresses'],
          align: 'left'
      },
      toolbox: {
          // y: 'bottom',
          feature: {
              magicType: {
                  type: ['stack', 'tiled']
              },
              dataView: {},
              saveAsImage: {
                  pixelRatio: 2
              }
          }
      },
      tooltip : {
         trigger: 'item',
         formatter : function (params) {
             data = 'Filename: '+params.value[3]+'<br/>';
             data+= 'Bytes: '+params.value[5]+'<br/>';
             data+= 'IP: '+params.value[4]+'<br/>';
             data+= 'Response, Request: '+params.value[0]+', '+params.value[1];
             return data;
         }
      },
      yAxis: {
          data: [],
          silent: false,
          splitLine: {
              show: false
          }
      },
      xAxis: {
      },
      series: [],
      animationEasing: 'elasticOut',
      animationDelayUpdate: function (idx) {
          return idx * 5;
      }
    };
  } else if(type == 'byte-res')  {
    option = {
      title : {
         text : 'General Server Performance',
         subtext : ''
      },
      tooltip : {
         trigger: 'item',
         formatter : function (params) {
             data = 'Filename: '+params.value[3]+'<br/>';
             data+= 'Bytes: '+params.value[5]+'<br/>';
             data+= 'IP: '+params.value[4]+'<br/>';
             data+= 'Response, Request: '+params.value[0]+', '+params.value[1];
             return data;
         }
      },
      toolbox: {
        feature: {
            dataZoom: {}
        }
      },
      xAxis: {
          type: 'value',
          name: 'Response Size(bytes)',
          nameGap: 16,
          nameTextStyle: {
              fontSize: 14
          },
          splitLine: {
              show: false
          },
      },
      yAxis: {
          type: 'value',
          name: 'Response Time(ms)',
          nameLocation: 'end',
          nameGap: 20,
          nameTextStyle: {
              fontSize: 16
          },
          splitLine: {
              show: false
          }
      },
      dataZoom: [{
          type: 'inside'
      }, {
          type: 'slider'
      }],

      series: [],

      legend: {
        data: [],
      }
    };
  }
  Grapher.makeGraph(type, option);
}

function clearGraph()  {
  Grapher.clearGraph();
}
