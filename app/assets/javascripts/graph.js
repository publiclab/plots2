function graphUrl(url, el) {
  $.get(url, function onGetGraphData(response) {
    graphCsv(response, el);
  });
}

function graphCsv(csv, el) {

  var data = [];
  var rows = csv.split('\n').slice(1);

  for (var i = 0; i < rows[0].split(',').length; i++) {
    data.push([]);
  }

  rows.forEach(function(row) {
    if (row !== '') {
      var cols = row.split(',');
      cols.forEach(function(col, i) {
        data[i].push(col);
      });
    }
  });

  return graph(data, el);
}

function dataToDatasets(data) {

  var colors = {
    "blue":"rgb(54, 162, 235)",
    "red":"rgb(255, 99, 132)",
    "green":"rgb(75, 192, 192)",
    "grey":"rgb(201, 203, 207)",
    "orange":"rgb(255, 159, 64)",
    "purple":"rgb(153, 102, 255)",
    "yellow":"rgb(255, 205, 86)"
  }
  var colorNames = Object.keys(colors);
  var datasets = [];
  data.forEach(function(data, i) {
    datasets.push({
      label: "Dataset " + i,
      backgroundColor: colors[colorNames[i]],
      borderColor: colors[colorNames[i]],
      data: data,
      fill: false,
    });
  });

  return datasets;
}

function graph(data, el) {

  el = el || "graph-canvas";
  data = data || [1, 2, 4, 1, 5];

  var datasets = dataToDatasets(data);

  var config = {
      type: 'line',
      data: {
          labels: Array.from(Array(data[0].length).keys()),
          datasets: datasets
      },
      options: {
        responsive: true,
        title:{
          display: false,
          // text:'Chart.js Line Chart'
        },
        tooltips: {
          mode: 'index',
          intersect: false,
        },
        hover: {
          mode: 'nearest',
          intersect: true
        },
        legend: {
          position: 'right',
        },
        scales: {
          xAxes: [{
            display: true,
            scaleLabel: {
              display: true,
              labelString: 'Time'
            }
          }],
          yAxes: [{
            display: true,
            scaleLabel: {
              display: true,
              labelString: 'Value'
            }
          }]
        }
      }
  };

  if(isTimeColumn(data[0])) {
    datasets.shift();
    config.options.scales.xAxes[0].type = "time";
    config.data.labels = data[0].map(function(x) {
      return moment(x, "YYYY/MM/DD hh:mm:ss").toDate();
    });
  }

  var ctx = document.getElementById(el).getContext("2d");

  var chart = new Chart(ctx, config);

  // work towards adaptive height to accommodate tons of datasets
  // without the labels squishing the graph:

  // var height = 300 + (datasets.length * 40);
  // $(el).height(height);
  // ctx.height = height;
  // console.log(datasets.length, height);

  return chart;
}

function isTimeColumn(col) {
  return col.every(function(x) {
    return moment(x, "YYYY/MM/DD hh:mm:ss").isValid();
  });
}
