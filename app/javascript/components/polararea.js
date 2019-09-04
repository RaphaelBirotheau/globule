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
      lineTension: 0.15,
      backgroundColor : ["rgba(255, 60, 2, 0.6)", "rgba(1, 127, 61, 0.6)","rgba(1, 196, 238, 0.6)"],
      pointRadius: 0, // supprimer si on veut faire apparaitre les points
      borderWidth: 2,
      borderJoinStyle: 'round',
      cubicInterpolationMode: 'monotone',
    }]
  };

  var options = {
    scale: {
      ticks: {
        max: 100
      }
    },
    responsive: true,
    legend: {
      display: false
    }
  };

  var myChart = new Chart(ctx, {
    type: 'polarArea',
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
