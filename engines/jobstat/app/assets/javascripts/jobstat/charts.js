function calculateTotal(data, index) {
    return data.map(hash => {
        var result = {};
        var total = 0;

        for (var key in hash) {
            result[key] = hash[key];
            if (key == index)
                continue;
            total += hash[key];
        }

        result.total = total;
        return result;
    });
}

function drawStackedBarChart(id, data, keys, index) {
    // calculate total amount
    var data = calculateTotal(data, index);

    // create the svg
    var margin = {top: 20, right: 20, bottom: 100, left: 40},
        width = 960 - margin.left - margin.right,
        height = 560 - margin.top - margin.bottom;
    var svg = d3.select("#" + id).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom);
    var g = svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // set x axis labels stide
    var MAXTICKS = 50;
    var domain = data.map(function (d) { return d[index]; });
    var stride = Math.ceil(domain.length / MAXTICKS);
    var ticks = domain.filter(function(v, i) { return i % stride === 0; });

    // set x/y scale 
    var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
        y = d3.scaleLinear().rangeRound([height, 0]);

    // set the colors
    var z = d3.scaleOrdinal(d3.schemeSet2);

    x.domain(data.map(function (d) {
        return d[index];
    }));

    y.domain([0, d3.max(data, function (d) {
        return d["total"];
    })]).nice();

    z.domain(keys);

    g.append("g")
        .selectAll("g")
        .data(d3.stack().keys(keys)(data))
        .enter().append("g")
        .attr("fill", function (d) {
            return z(d.key);
        })
        .selectAll("rect")
        .data(function (d) {
            return d;
        })
        .enter().append("rect")
        .attr("x", function (d) {
            return x(d.data[index]);
        })
        .attr("y", function (d) {
            return y(d[1]);
        })
        .attr("height", function (d) {
            return y(d[0]) - y(d[1]);
        })
        .attr("width", x.bandwidth())
        .on("mouseover", function () {
            tooltip.style("display", null);
        })
        .on("mouseout", function () {
            tooltip.style("display", "none");
        })
        .on("mousemove", function (d) {
            var xPosition = d3.mouse(this)[0] - 5;
            var yPosition = d3.mouse(this)[1] - 20;
            var value = d[1] - d[0];

            tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
            tooltip.select("text").text("Val: " + value);
        });

    g.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.axisBottom(x).tickValues(ticks))
        .selectAll("text")
        .attr("y", 0)
        .attr("x", 9)
        .attr("dy", ".35em")
        .attr("transform", "rotate(65)")
        .style("text-anchor", "start");

    g.append("g")
        .attr("class", "axis")
        .call(d3.axisLeft(y).ticks(null, "s"))
        .append("text")
        .attr("x", 2)
        .attr("y", y(y.ticks().pop()) + 0.5)
        .attr("dy", "0.35em")
        .attr("fill", "#000")
        .attr("font-weight", "bold")
        .attr("text-anchor", "start");

    if (keys.length <= 7) {
        var legend = g.append("g")
            .attr("font-family", "sans-serif")
            .attr("font-size", 10)
            .attr("text-anchor", "end")
            .selectAll("g")
            .data(keys.slice().reverse())
            .enter().append("g")
            .attr("transform", function (d, i) {
                return "translate(0," + i * 20 + ")";
            });

        legend.append("rect")
            .attr("x", width - 19)
            .attr("width", 19)
            .attr("height", 19)
            .attr("fill", z);

        legend.append("text")
            .attr("x", width - 24)
            .attr("y", 9.5)
            .attr("dy", "0.32em")
            .text(function (d) {
                return d;
            });
    }

    // Prep the tooltip bits, initial display is hidden
    var tooltip = svg.append("g")
        .attr("class", "tooltip")
        .style("opacity", 0.8)
        .style("display", "none");

    tooltip.append("rect")
        .attr("width", 100)
        .attr("height", 30)
        .attr("fill", "green");

    tooltip.append("text")
        .attr("x", 50)
        .attr("y", 15)
        .attr("dy", "0.4em")
        .style("text-anchor", "middle")
        .attr("font-size", "12px")
        .attr("font-weight", "bold");
}

function drawTopBarChart(id, data) {
    var margin = { top: 20, right: 20, bottom: 30, left: 50 },
        width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom,
        svg = d3.select("#" + id).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g");

    var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
        y = d3.scaleLinear().rangeRound([height, 0]);
    var g = svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain(data.map(function (d) {
        return d.login;
    }));
    y.domain([0, d3.max(data, function (d) {
        return d.count;
    })]);

    g.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + (height + 0) + ")")
        .call(d3.axisBottom(x));
    g.append("g")
        .attr("class", "axis axis--y")
        .call(d3.axisLeft(y))
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "0.71em")
        .attr("text-anchor", "end")
        .text("Frequency");

    g.selectAll(".bar")
        .data(data)
        .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function (d) {
            return x(d.login);
        })
        .attr("y", function (d) {
            return y(d.count);
        })
        .attr("width", x.bandwidth())
        .attr("height", function (d) {
            return height - y(d.count);
        });
    g.selectAll(".bar")
        .attr("fill", function (d) {
            return "steelblue";
        });
}