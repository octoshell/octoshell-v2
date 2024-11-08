$ ->
  google.setOnLoadCallback ->
    width = 720
    height = 300
    titleTextStyle =
      fontSize: 18

    $('.graph-pie').each (i, html) ->
      $graph = $(html)

      source = $graph.data('source')
      data = new google.visualization.DataTable();
      data.addColumn 'string', 'Name'
      data.addColumn 'number', 'Count'
      data.addRows(source)

      options =
        title: ""
        titleTextStyle: titleTextStyle
        width: width
        height: height

      chart = new google.visualization.PieChart($graph[0])
      chart.draw data, options

    $('.graph-bar').each (i, html) ->
      $graph = $(html)

      table = []

      source = $graph.data('source')

      data = new google.visualization.DataTable();
      data.addColumn 'string', 'Название'
      data.addColumn 'number', 'Количество'
      data.addRows($graph.data('source'))

      options =
        title: ""
        titleTextStyle: titleTextStyle
        width: width
        height: height
        hAxis:
          slantedText: true
          textStyle:
            fontSize: 12

      chart = new google.visualization.ColumnChart($graph[0])
      chart.draw data, options

    $('.cohort').each (i, html) ->
      setTimeout(->
        $graph = $(html)
        data = google.visualization.arrayToDataTable($graph.data("chart"))
        chart = new google.visualization.ColumnChart($graph[0])
        width = (data.getNumberOfRows() * data.getNumberOfColumns() * 12)
        unless width > 940
          width = 940
        options =
          height: height
          width: width
          chartArea: { width: width - 100, height: '61%' }
          hAxis:
            textStyle:
              fontSize: 14
          vAxis:
            textStyle:
              fontSize: 14
          tooltip:
            textStyle:
              fontSize: 14
          legend:
            textStyle:
              fontSize: 14
            position: 'top'
        chart.draw(data, options)
      , 500 * i)
