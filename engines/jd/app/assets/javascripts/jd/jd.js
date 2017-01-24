// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function ConvertForMultiLine(input)
{
    var header = ["min", "max", "avg", "avg_min", "avg_max"];

    var data = [];

    for(var i = 1; i < input.length; i++)
    {
        var tmp = [];

        tmp.push(new Date(input[i]["time"]*1000));

        for(var j = 0; j < header.length; j++)
            tmp.push(parseFloat(input[i][header[j]]));

        data.push(tmp);
    }

    return data;
}

function LoadOne(name, task_id){
    jQuery.get("/jd/api/job/" + task_id + "/" + name, function(input) {
        var raw_data = ConvertForMultiLine(input);

        var ticks = [];


        var options = {
//            title: name
            legend: { position: 'bottom' }
            , 'chartArea': {backgroundColor: "#f8f8f8", left: 50, top: 20, 'height': '80%', 'width': '100%'}
            ,  hAxis: { format: 'HH:mm' } // 'dd/MM/yyyy HH:mm'
            , vAxis: {format: 'short'}
            , 'height': 400
            , series: {
                0: { lineWidth: 2 },
                1: { lineWidth: 2 },
                2: { lineWidth: 2 },
                3: { lineWidth: 2 },
                4: { lineWidth: 2 }
            }
            , colors: ['#c0504d', '#4bacc6', '#95b456', '#7b609c', '#f79646']
        };

        var data = new google.visualization.DataTable();
        data.addColumn('datetime', 'time');
        data.addColumn('number', 'min');
        data.addColumn('number', 'max');
        data.addColumn('number', 'avg');
        data.addColumn('number', 'avg_min');
        data.addColumn('number', 'avg_max');
        data.addRows(raw_data);

        var chart = new google.visualization.LineChart(document.getElementById(name));

        google.visualization.events.addListener(chart, "select", function() { highlightLine(chart, data, options); });

        chart.draw(data, options);
    });
}

function highlightLine(chart, data, options) {
    var def_lw = 2;
    var unselected_lw = 1;
    var selected_lw = 4;

    var last_selected = -1;
    var selected = chart.getSelection()[0].column - 1;

    for(var i in options.series) {
        if(options.series[i].lineWidth == selected_lw)
            last_selected = i;
    }

    if(selected == last_selected) // unselect
    {
        for(var i in options.series) {
            options.series[i].lineWidth = def_lw;
        }
    }
    else // select
    {
        for(var i in options.series) {
            options.series[i].lineWidth = unselected_lw;
        }
        options.series[selected].lineWidth = selected_lw;
    }

    chart.draw(data, options); //redraw
}

function LoadData(task_id, with_gpu) {
    var sensors = ["llc_miss", "cpu_perf_l1d_repl", "cpu_flops", "mem_load", "mem_store", "cpu_user", "cpu_nice", "cpu_system", "cpu_idle", "cpu_iowait", "cpu_irq", "cpu_soft_irq", "ib_rcv_data", "ib_xmit_data", "ib_rcv_pckts", "ib_xmit_pckts", "loadavg"];
    var gpu_sensors = ["gpu_load", "gpu_mem_load", "gpu_mem_usage"];

    for(var i = 0; i < sensors.length; i++)
        LoadOne(sensors[i], task_id);

    if(with_gpu)
        for(var i = 0; i < gpu_sensors.length; i++)
            LoadOne(gpu_sensors[i], task_id);
}

function ApplyToggle(){
    $('.graph').each(function(i) {
        var button = $('<input type="button" value="show/hide" style="float:right;"></input>');
        var graph = this;

        $(graph).after(button);

        var id = graph.id;
        var new_id = id + "_button";

        $(button).attr("id", new_id);

        $("body").on('click', "#" + new_id, function(){
            $(graph).toggle(200);
        });
    });

    ToggleInfo();
}

function ToggleInfo(){
    $('.info').each(function(i) {
        $(this).toggle(200);
    });
}

function ToggleAll(){
    $('.graph').each(function(i) {
        $(this).toggle(200);
    });
}
