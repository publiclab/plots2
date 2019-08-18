function determineType2(graphType){
    if (graphType === "Horizontal" || graphType === "Vertical"){
        return "bar";
    } 
    else if (graphType === "Pie" || graphType === "Doughnut" || graphType === "Radar" ){
        return "pie";
    }
    else {
        return "scatter";
    }
}
function layoutMaker(graphType){
    let layout = {};
    if (graphType === "Horizontal" || graphType === "Vertical"){
        layout["barmode"] = "group";
    }
    return layout;
}
function traceMaker(graphType){
    let trace = {};
    trace["type"] = determineType2(graphType);
    if (graphType === "Horizontal"){
        trace["orientation"] = "h";
    }
    else if (graphType === "Doughnut"){
        trace["hole"] = 0.5;
    }
    else if (graphType === "Basic"){
        trace["mode"] = "lines";
    }
    else if (graphType === "Point"){
        trace["mode"] = "markers";
    }
    else if (graphType === "Stepped"){
        trace["mode"] = "lines+markers";
        trace["line"] = {"shape": 'hv'};
    }
    return trace;
}
function keyDeterminer(graphType){
    let keys = ["x","y"];
    if (graphType === "Pie" || graphType === "Doughnut"){
        keys[1] = "values";
        keys[0] = "labels";
    }
    else if (graphType === "Horizontal"){
        keys[0] = "y";
        keys[1] = "x";
    }
    return keys;
}
function plotGraph2(dataHash,length,graphType,divId){
    let layout = layoutMaker(graphType);
    let data = [];
    let keySet = keyDeterminer(graphType);
    for (let i = 0;i<length;i++){
        let new_trace = traceMaker(graphType);
        new_trace[keySet[0]] = dataHash['x_axis_labels'];
        new_trace[keySet[1]] = dataHash['y_axis_values'+i];
        new_trace["name"] = dataHash['labels'][1][i];
        data.push(new_trace);
    }   
    Plotly.newPlot(divId,data,layout);
    
}
function graphMaker(data,divId){
    let obj = data["sdgobject"];
    let actualHash = JSON.parse(obj);
    let dataHash = actualHash["hash"];
    let length = actualHash["length"];
    let graphType = actualHash["graphType"];
    plotGraph2(dataHash,length,graphType,divId);
}