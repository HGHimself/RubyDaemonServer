var weekday = new Array();
weekday[0] = "Sunday";
weekday[1] = "Monday";
weekday[2] = "Tuesday";
weekday[3] = "Wednesday";
weekday[4] = "Thursday";
weekday[5] = "Friday";
weekday[6] = "Saturday";

option = {
  title : {
       text : 'Account Spendature',
       subtext : ''
   },
   tooltip : {
       trigger: 'item',
       formatter : function (params) {

           var date = new Date(params.value[0]);
           data = weekday[date.getDay()] + ', ' + date.getFullYear() + '/'
                  + (date.getMonth() + 1) + '/'
                  + date.getDate() + ' '
           return data + '<br/>'
                  + '$' + params.value[1];
       }
   },
   toolbox: {
       show : true,
       feature : {
           mark : {show: true},
           dataView : {show: true, readOnly: false},
           restore : {show: true},
           saveAsImage : {show: true}
       }
   },
   dataZoom: {
       show: true,
       start : 70
   },
   legend : {
       data : ['Balance', 'Total Income']
   },
   grid: {
       y2: 80
   },
   xAxis : [
       {
           type : 'time',
           splitNumber:10
       }
   ],
   yAxis : [
       {
           type : 'value'
       }
   ],
  series : [
      {
        name: 'Total Income',
        type: 'line',
        showAllSymbol: true,
        symbolSize: 20,
        data: (function() {
          var d = [
            ['2/21/19', 100.00], ['3/5/19', 1167.38], ['3/19/19', 2663.38],
            ['4/2/19', 4105.38], ['4/16/19', 5574.38],
          ]

          d.forEach(function(element) {
            element[0] = new Date(element[0]);
            element.push()
          });

          return d;
        })()
      },
      {
          name: 'Balance',
          type: 'line',
          showAllSymbol: true,
          symbolSize: 20,
          data: (function() {
            var d = [
              ['2/21/19', 100.00], ['3/5/19', 1167.39], ['3/6/19', 1153.89],
              ['3/8/19', 1143.94], ['3/11/19', 902.88], ['3/12/19', 878.90],
              ['3/13/19', 854.74], ['3/18/19', 620.70], ['3/19/19', 2032.20],
              ['3/20/19', 2024.38], ['3/22/19', 1841.34], ['3/25/19', 1653.59],
              ['3/26/19', 1545.91], ['3/27/19', 1505.04], ['3/29/19', 1472.54],
              ['4/1/19', 1172.53], ['4/2/19', 2641.53], ['4/5/19', 2598.04],
              ['4/8/19', 2498.84], ['4/9/19', 2473.10], ['4/10/19', 2461.15],
              ['4/12/19', 2441.15], ['4/15/19', 2169.78], ['4/16/19', 3218.59],
              ['4/17/19', 3187.10], ['4/19/19', 3167.08],
            ]

            d.forEach(function(element) {
              element[0] = new Date(element[0]);
              element.push()
            });

            return d;
          })()
      },
  ]
};

var theme = {
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

    // 网格
    grid: {
        borderWidth:0
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
var barGraph = echarts.init(document.getElementById('data-usage'), theme);

barGraph.setOption(option, true), $(function () {
    function resize() {
        setTimeout(function () {
            barGraph.resize()
        }, 100)
    }
    $(window).on("resize", resize);
});
