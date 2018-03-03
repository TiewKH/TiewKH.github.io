function drawSankey(i){
	//Hide Sankey svg
	d3.selectAll(".sankey")
		.style("opacity", 0)
		.remove();

	var sankey_box = d3.select(".sankey-container")
		.append("svg")
		.attr("class", "sankey")
		.attr("width", sankey_width)
		.attr("height", sankey_height)
		.append("g");

	//Hide Sankey svg
	d3.selectAll(".sankey")
		.style("opacity", 0);

	//Hide flow canvas 
	d3.selectAll("canvas")
		.style("opacity", 0);	

	// Set the sankey diagram properties
	var sankey = d3.sankey()
		.nodeWidth(20)
		.nodePadding(40)
		.size([sankey_width, sankey_height]);

	var path = sankey.link();
	
	var freqCounter = 1;
	// format variables
	var formatNumber = d3.format(",.0f"),    // zero decimal places
	format = function(d) { return formatNumber(d) + " " + units; },
	color_sankey = d3.scaleOrdinal()
					.domain(["Violent Crime","Murder Nonnegligent Manslaughter","Rape","Robbery","Aggravated Assault","Property Crime","Burglary","Larceny Theft","Motor Vehicle Theft"])
					.range(["#e6194b", "#3cb44b" , "#CCCC00", "#ff69b4", "#aa6e28", "#f032e6", "#808080", "#ff8300", "#000080"]);

	sankey_data = sankey_full_data.filter(function(d){ return d.source == mapping[i][1];});
	//Clear out zero entries to prevent error
	sankey_data = sankey_data.filter(function(d){return d.value != 0;});

	var graph = {"nodes" : [], "links" : []};


	sankey_data.forEach(function (d) {
	      graph.nodes.push({ "name": d.source });
	      graph.nodes.push({ "name": d.target });
	      graph.links.push({ "source": d.source,
	                         "target": d.target,
	                         "value": +d.value });
	     });

	 // return only the distinct / unique nodes
	graph.nodes = d3.keys(d3.nest()
		.key(function (d) { return d.name; })
		.object(graph.nodes));

	// loop through each link replacing the text with its index from node
	graph.links.forEach(function (d, i) {
		graph.links[i].source = graph.nodes.indexOf(graph.links[i].source);
		graph.links[i].target = graph.nodes.indexOf(graph.links[i].target);
	});

	//now loop through each nodes to make nodes an array of objects
	// rather than an array of strings
	graph.nodes.forEach(function (d, i) {
		graph.nodes[i] = { "name": d };
	});

	sankey
      .nodes(graph.nodes)
      .links(graph.links)
      .layout(32);

	// add in the links
	var link = sankey_box.append("g").selectAll(".link")
		.data(graph.links)
		.enter().append("path")
		.attr("class", "link")
		.attr("d", path)
		.style("stroke-width", function(d) { return Math.max(10, d.dy); })
		.sort(function(a, b) { return b.dy - a.dy; });

	// add the link titles
	link.append("title")
		.text(function(d) {
		return d.source.name + " → " + 
		d.target.name + "\n" + format(d.value); });

	// add in the nodes
	var node = sankey_box.append("g").selectAll(".node")
		.data(graph.nodes)
		.enter().append("g")
		.attr("class", "node")
		.attr("transform", function(d) { 
			return "translate(" + d.x + "," + d.y + ")"; })
		.call(d3.drag()
		.subject(function(d) {
			return d;
		})
		.on("start", function() {
		this.parentNode.appendChild(this);
		})
		.on("drag", dragmove));

	// add the rectangles for the nodes
	node.append("rect")
		.attr("height", function(d) { return d.dy; })
		.attr("width", sankey.nodeWidth())
		.style("fill", function(d) { 
			if(color_sankey.domain().indexOf(d.name) > -1){
				return d.color = color_sankey(d.name.replace(/ .*/, ""));
			} else {
				return d.color = '#0051A3';
			}
		}) 
		.style("stroke", function(d) { 
			return d3.rgb(d.color).darker(2); })
		.append("title")
		.text(function(d) { 
			return d.name + "\n" + format(d.value); });

	// add in the title for the nodes
	node.append("text")
		.style("font-size","30px")
		.attr("x", -6)
		.attr("y", function(d) { return d.dy / 2 - 5; })
		.attr("dy", ".35em")
		.attr("text-anchor", "end")
		.attr("transform", null)
		.text(function(d) { return d.name; })
		.filter(function(d) { return d.x < width / 2; })
		.attr("x", 6 + sankey.nodeWidth())
		.attr("text-anchor", "start");

	// the function for moving the nodes
	function dragmove(d) {
		d3.select(this)
		.attr("transform", 
		"translate(" 
		+ d.x + "," 
		+ (d.y = Math.max(
		  0, Math.min(height - d.dy, d3.event.y))
		 ) + ")");
		sankey.relayout();
		link.attr("d", path);
		}
//Particle Animation Code
	var linkExtent = d3.extent(graph.links, function (d) {return d.value});

	var frequencyScale = d3.scaleLinear().domain(linkExtent).range([1,100]);
	var particleSize = d3.scaleLinear().domain(linkExtent).range([1,5]);

	graph.links.forEach(function (link) {
		link.freq = frequencyScale(link.value);
		link.particleSize = particleSize(link.value);
		link.particleColor = d3.scaleLinear().domain([1,1000]).range([link.source.color, link.target.color]);
	})

	var t = d3.timer(tick, 1000);
	var particles = [];

	function tick(elapsed, time) {

	particles = particles.filter(function (d) {return d.time > (elapsed - 1000)});

	if (freqCounter > 100) {
		freqCounter = 1;
	}

	d3.selectAll("path.link")
		.each(
		function (d) {
			if (d.freq >= freqCounter) {
				var offset = (Math.random() - .5) * d.dy;
				particles.push({link: d, time: elapsed, offset: offset, path: this})
			}
		});

		particleEdgeCanvasPath(elapsed);
		freqCounter++;
		}

	function particleEdgeCanvasPath(elapsed) {
		var context = d3.select("canvas").node().getContext("2d")

		context.clearRect(0,0,1000,1000);

		context.fillStyle = "gray";
		context.lineWidth = "1px";
		for (var x in particles) {
			var currentTime = elapsed - particles[x].time;
			var currentPercent = currentTime / 1000 * particles[x].path.getTotalLength();
			var currentPos = particles[x].path.getPointAtLength(currentPercent)
			context.beginPath();
			context.fillStyle = particles[x].link.particleColor(currentTime);
			context.arc(currentPos.x,currentPos.y + particles[x].offset,particles[x].link.particleSize,0,2*Math.PI);
			context.fill();
		}
	}
//Particle Animation Code End
	//Show Sankey svg
	d3.selectAll(".sankey")
		.transition()
		.duration(500)
		.delay(1000)
		.style("opacity", 1);	

	//Show canvas
	d3.selectAll("canvas")
		.transition()
		.delay(1000)
		.style("opacity", 1);		
}