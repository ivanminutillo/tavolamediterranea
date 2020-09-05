// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import {Chart} from 'chart.js'


let Hooks = {}

Hooks.Emocromo = {
    mounted(){
     let dataset = JSON.parse(this.el.dataset.emo)
     let labels = JSON.parse(this.el.dataset.labels)
     dataset.map(i => {
      var ctx = document.getElementById(i.name);
      let min = i.min == null ? 0 : i.min
      let max = i.max 
      let annotation
      if (max == null) {
        annotation = {
            type: 'box',
            drawTime: 'beforeDatasetsDraw',
            yScaleID: 'y-axis-0',
            yMin: min,
            yMax: min + .1,
            backgroundColor: 'rgba(0, 255, 0, 1)'
         }
      } else {
        annotation = {
            type: 'box',
            drawTime: 'beforeDatasetsDraw',
            yScaleID: 'y-axis-0',
            yMin: min,
            yMax: max,
            backgroundColor: 'rgba(0, 255, 0, 0.1)'
         }
      }
      return new Chart(ctx, {
       type: 'line',
       data: {
        labels: labels,
        datasets: [{
              fill: false,
              data: i.value,
              borderWidth: 1,
              borderColor: "#286cbf",
        }]
       },
       options: {
        legend: {
         display: false
        },
        annotation: {
         annotations: [annotation]
        },
        bezierCurve:false, //remove curves from your plot
        scaleShowLabels : false, //remove labels
        tooltipEvents:[], //remove trigger from tooltips so they will'nt be show
        pointDot : false, //remove the points markers
        scaleShowGridLines: true, //set to false to remove the grids background
           scales: {
               yAxes: [{
                   ticks: {
                       beginAtZero: true
                   }
               }]
           }
       }
      });
     })
     
    }
  }

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

