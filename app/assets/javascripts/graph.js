function graphUrl(url, el) {
console.log('graphUrl');
  $.get(url, function onGetGraphData(response) {
    graphCsv(response, el);
  });
}

function graphCsv(csv, el) {

  var data = [];
  var rows = csv.split('\n');

  for (var i = 0; i < rows[0].split(',').length; i++) {
    data.push([]);
  }

  rows.forEach(function(row) {
    if (row !== '') {
      var cols = row.split(',');
      cols.forEach(function(col, i) {
        data[i].push(parseFloat(col));
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
          //labels: ["January", "February", "March", "April", "May", "June", "July"],
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

  var ctx = document.getElementById(el).getContext("2d");

  return new Chart(ctx, config);

}
