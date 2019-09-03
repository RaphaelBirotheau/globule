import Chart from "chart.js"

const chartPolarArea = () => {
  console.log("prout");




  var ctx = document.getElementById("polar-chart").getContext('2d');

  var data = {
    labels: ["Health","Environment","Social"],
    datasets: [{
      data: [80, 40, 56],
      fill: true,
      lineTension: 0.15,
      backgroundColor : ["#FF3C02", "#017F3D","#01C4EE"],
      pointRadius: 0, // supprimer si on veut faire apparaitre les points
      borderWidth: 2,
      borderJoinStyle: 'round',
      cubicInterpolationMode: 'monotone',
    }]
  };

  var options = {
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

export { chartPolarArea };
