//Code adopted from https://bl.ocks.org/stevenwmarks/c23bf3940bc5f1ee4027ccc72097a03b
var count = 0;
function drawSmallMultiples(){ 
    // width, height, margins and padding
	var margin = {top: 40, right: 30, bottom: 40, left: 30},
		width = 145 - margin.left - margin.right,
		height = 250;

	var div = d3.select("#small-multiples-container").append("div")
                .attr("class", "smallmultipletooltip")
                .style("opacity", 0);
                
    var color = d3.scaleOrdinal().domain(["ViolentCrime","MurderAndNonnegligentManslaughter","Rape","Robbery","AggravatedAssault","PropertyCrime","Burglary","LarcenyTheft","MotorVehicleTheft"]).range(["#e6194b", "#3cb44b" , "#CCCC00", "#ff69b4", "#aa6e28", "#f032e6", "#808080", "#ff8300", "#000080"]);
    
	// load data
	d3.csv("data_diff.csv", type, function(error, data) {	
    
		// scales
        var xScale = d3.scaleLinear()
            .range([0, width]);
            
        var yScale = d3.scaleBand()
            .rangeRound([0, height])
            .paddingInner(0.1);
        
        var formatAsPercentage = d3.format("1.0%");
            
		//console.log(data);
		
		// domains
//		xScale.domain([-.23, .18]); // approximates values in csv

        
		var dataNestDiff = d3.nest()
                        .key(function(d) {return d.variable;})
                        .entries(data);
        //console.log();
        //console.log(dataNestDiff.filter(function(e) {return e.key == "ViolentCrime";}))
                        
        for(j = 0; j < dataNestDiff.length; j++){
                        
            //console.log(my_data);
            // define X axis
            var xAxis = d3.axisBottom().scale(xScale).tickFormat(formatAsPercentage).ticks(2);
            
            xScale.domain(d3.extent(dataNestDiff[j].values, function(d) { return d.yoy; })).nice(2).domain();
            yScale.domain(dataNestDiff[j].values.map(function(d) { return d.Year; }));
                                    
            svg_id = "bar-chart-svg" + j;
                                    
            // create svg
            var svg = d3.select("#small-multiples-container")
                .append("svg")
                    .attr("width", width + margin.left + margin.right)
                    .attr("height", height + margin.top + margin.bottom)
                    .attr("id", svg_id)
                .append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
                    
            //Append Title
            current_category = dataNestDiff[j].key.replace(/([a-z])([A-Z])/g, '$1 $2');
            
            if(current_category != 'Murder And Nonnegligent Manslaughter'){
                d3.select("svg#" + svg_id).append("svg:text")
                    .attr("x", (width + margin.left + margin.right)/2)             
                    .attr("y", 25)
                    .attr("text-anchor", "middle")  
                    .attr("fill", color(dataNestDiff[j].key))
                    .style("font-size", "1em") 
                    .text(current_category)
                    .on("click", function(d){
                    	if(count == 0){
                    		name = this.innerHTML.replace(/\s/g, '');
	                    	//console.log(name);
	                		d3.select("#overlay").style('display', 'block')
	                			.on("click", function(){
	                				this.style.display = 'none';
	                				d3.select('#overlay').selectAll("*").remove();
	                				count = 0;
	                			});
	                		drawBarChart(dataNestDiff.filter(function(e) {return e.key == name;}), color);
	                		count = 1;
                    	}
                	})
            }
            else{
                d3.select("svg#" + svg_id).append("svg:text")
                    .attr("x", (width + margin.left + margin.right)/2)             
                    .attr("y", 20)
                    .attr("text-anchor", "middle")  
                    .style("font-size", "1em") 
                    .style("fill", color(dataNestDiff[j].key))
                    .text("Murder And")
                    .on("click", function(d){
                		if(count == 0){
                    		name = "MurderAndNonnegligentManslaughter";
	                    	//console.log(name);
	                		d3.select("#overlay")
	                		.style('display', 'block')
	                			.on("click", function(){
	                				this.style.display = 'none';
	                				d3.select('#overlay').selectAll("*").remove();
	                				count = 0;
	                			});
	                		drawBarChart(dataNestDiff.filter(function(e) {return e.key == name;}), color);
	                		count = 1;
                    	}
                	})

                d3.select("svg#" + svg_id).append("svg:text")
                    .attr("x", (width + margin.left + margin.right)/2)             
                    .attr("y", 30)
                    .attr("text-anchor", "middle")  
                    .style("font-size", "1em") 
                    .style("fill", color(dataNestDiff[j].key))
                    .text("Nonnegligent Manslaughter")
                    .on("click", function(d){
                		name = "MurderAndNonnegligentManslaughter";
	                    	//console.log(name);
	                		d3.select("#overlay")
	                		.style('display', 'block')
	                			.on("click", function(){
	                				this.style.display = 'none';
	                				d3.select('#overlay').selectAll("*").remove();
	                				count = 0;
	                			});
	                		drawBarChart(dataNestDiff.filter(function(e) {return e.key == name;}), color);
	                		count = 1;
                	})

            }
            
            // format tooltip
            var thsndFormat = d3.format(",");

            // create  bars
            svg.selectAll(".bar")
                .data(dataNestDiff[j].values)
                .enter()
                .append("rect")
                    .attr("class", function(d) { return "bar bar--" + (d.yoy < 0 ? "negative" : "positive"); })
                    .attr("x", function(d) { return xScale(Math.min(0, d.yoy)); })
                    .attr("y", function(d) { return yScale(d.Year); })
                    .attr("width", function(d) { return Math.abs(xScale(d.yoy) - xScale(0)); })
                    .attr("height", yScale.bandwidth()) 
                .on("mouseover", function(d) {
                        //Get previous year
                        var previousYear = d.Year - 1;
                        //console.log(previousYear);
                        div.transition().duration(200).style("opacity", 0.8);
                        div.html("YoY Growth " + previousYear + " to " + d.Year + "<br>Percentage: " + (d.yoy*100).toFixed(2) + "\%<br> Count: " + thsndFormat(d.diff))
                            .style("left", (d3.event.pageX) + "px")
                            .style("top", (d3.event.pageY - 28) + "px")
                            .style("text-align", "center");
                    })
                .on("mouseout", function(d) {
                    div.transition().duration(500).style("opacity", 0);
                })
                 
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")  
                .call(xAxis);					 
                
            // add tickNegative
            var tickNeg = svg.append("g")
                    .attr("class", "y axis")
                    .attr("transform", "translate(" + xScale(0) + ",0)")
                    .call(d3.axisLeft(yScale))
                    .selectAll(".tick")
                        .filter(function(d, i) { return (dataNestDiff[j].values[i].yoy < 0); });

            tickNeg.select("line")
                .attr("x2", 6);
                
            tickNeg.select("text")
                .attr("x", 9)
                .style("text-anchor", "start");		
                
        }
    })
		function type(d) {
              d.yoy = +d.yoy;
              return d;
            }
}


function drawBarChart(data, color, type){

	//console.log(data[0].values);

	var margin = {top: 80, right: 80, bottom: 30, left: 80},
		width = 1000 - margin.left - margin.right,
		height = 400 - margin.top - margin.bottom;

	var div = d3.select("#overlay").append("div")
                .attr("class", "bigtooltip")
                .style("opacity", 0);

	// scales
    var big_bar_chart_xScale = d3.scaleLinear()
        .range([0, width]);
            
    var big_bar_chart_yScale = d3.scaleBand()
        .rangeRound([0, height])
        .paddingInner(0.1);

    var big_bar_chart_formatAsPercentage = d3.format("1.0%");

    var big_bar_chart_xAxis = d3.axisBottom().scale(big_bar_chart_xScale).tickFormat(big_bar_chart_formatAsPercentage).ticks(5);
            
    big_bar_chart_xScale.domain(d3.extent(data[0].values, function(d) { return d.yoy; })).nice(5).domain();
    big_bar_chart_yScale.domain(data[0].values.map(function(d) { return d.Year; }));


    // create svg
    var big_bar_chart_svg = d3.select("#overlay")
                			.append("svg")
                    		.attr("preserveAspectRatio", "xMinYMin meet")
                            .attr("viewBox", "0 0 1000 800")
                    		.attr("id", "big_bar_chart")
                			.append("g")
                    			.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.select("svg#big_bar_chart").append("svg:text")
        .attr("x", 1000/2)             
        .attr("y", 50)
        .attr("text-anchor", "middle")  
        .attr("fill", color(data[0].key))
        .style("font-size", "2em") 
        .text(data[0].key.replace(/([a-z])([A-Z])/g, '$1 $2'))

    // format tooltip
    var thsndFormat = d3.format(",");

    // create  bars
    bars = big_bar_chart_svg.selectAll(".bar")
        .data(data[0].values)
        .enter()
        .append("rect")
        .attr("class", function(d) { return "bar bar--" + (d.yoy < 0 ? "negative" : "positive"); })
        .attr("x", function(d) { return big_bar_chart_xScale(Math.min(0, d.yoy)); })
        .attr("y", function(d) { return big_bar_chart_yScale(d.Year); })
        .attr("width", function(d) { return Math.abs(big_bar_chart_xScale(d.yoy) - big_bar_chart_xScale(0)); })
        .attr("height", big_bar_chart_yScale.bandwidth()) 
        .on("mouseover", function(d) {
            //Get previous year
            var previousYear = d.Year - 1;
            //console.log(previousYear);
            div.transition().duration(200).style("opacity", 0.8);
            div.html("YoY Growth " + previousYear + " to " + d.Year + "<br>Percentage: " + (d.yoy*100).toFixed(2) + "\%<br> Count: " + thsndFormat(d.diff))
                .style("left", (d3.mouse(this)[0]) + "px")
                .style("top", (d3.mouse(this)[1] + 100) + "px")
                .style("text-align", "center")
            })
            .on("mouseout", function(d) {
                div.transition().duration(500).style("opacity", 0);
            })

    big_bar_chart_svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")  
        .call(big_bar_chart_xAxis);					 
                
    // add tickNegative
    var tickNeg = big_bar_chart_svg.append("g")
                    .attr("class", "y axis")
                    .attr("transform", "translate(" + big_bar_chart_xScale(0) + ",0)")
                    .call(d3.axisLeft(big_bar_chart_yScale))
                    .selectAll(".tick")
                        .filter(function(d, i) { return (data[0].values[i].yoy < 0); });

    tickNeg.select("line")
        .attr("x2", 6);
                
    tickNeg.select("text")
        .attr("x", 9)
        .style("text-anchor", "start");	
}