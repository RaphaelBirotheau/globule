import Chart from "chart.js"

const chartPolarArea = (chart) => {
  console.log("prout");

const datas = chart.dataset.values;
console.dir(datas);
const dataset = JSON.parse(datas);
console.dir(dataset);

  var ctx = chart.getContext('2d');

  var data = {
    labels: ["Health","Environment","Social"],
    datasets: [{
      data: dataset,
      fill: true,
      lineTension: 0,
      backgroundColor : ["rgba(39, 222, 189, 0.6)"],
      pointRadius: 2, // supprimer si on veut faire apparaitre les points
      borderWidth: 2,
      borderJoinStyle: 'bevel',
      cubicInterpolationMode: 'monotone',
    }]
  };

  var options = {
    // tooltips: {
    //   enabled: true,
    //   backgroundColor: red
    // },
    scale: {
      ticks: {
        max: 100,
        display: true,
      }
    },
    responsive: true,
    legend: {
      display: false,
    },
    layout: {
      padding: {
        left: 10,
        right: 0,
        top: 0,
        bottom: 0
      }
    }
  };

  var myChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options,
  });

  // new Chart(document.getElementById("polar-chart"), {
  //   type: 'polarArea',
  //   data: {
  //     labels: ["Health", "Environment", "Social"],
  //     datasets: [
  //       {
  //         label: "Population (millions)",
  //         backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f"],
  //         data: [80,39,55]
  //       }
  //     ]
  //   },
  //   options: {

  //   }
  // });

}


const initPolarArea = () => {
  const charts = document.querySelectorAll(".polar-chart");
  charts.forEach( (chart) => {
    chartPolarArea(chart);
  })
}

export { initPolarArea };
