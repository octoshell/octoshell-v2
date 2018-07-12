$(document).ready(function() {
  $("#jobs").tablesorter({
    //debug: true,
    duplicateSpan: false,
    emptyTo: 'bottom',
    widgets: ['staticRow'],
    theme: 'blue',
    textExtraction: {
      //0: function(node, table, cellIndex) { return $(node).find("strong").text(); },
      '.rank': function(node, table, cellIndex) {
        return $(node).find("i").attr('data-stars')
          /*var x=$(node).find("i").attr('data-stars');
          console.log("!"+x);
          return x;*/
      },
    },
    textSorter: {
      '.triplesort': function(a, b, direction, column, table) {
        // this is the original sort method from tablesorter 2.0.3
        var item = $(table).attr('data-triple-sort')
        if (typeof(item) === 'undefined') {
          console.log("Warning! No data-triple-sort specified...")
          item = '0'
        } else {
          item = parseInt(item)
        }
        // format data for normalization
        var x = parseFloat(a.split('/')[item])
        var y = parseFloat(b.split('/')[item])
          //console.log("sorting-by: "+item+"a="+a+" b="+b+" x="+x+" y="+y)
        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
      },
    },
  });

  $(".sorting").click(function() {
    var $t = $(this),
      col = $t.attr('data-column'),
      dir = $t.attr('data-direction'),
      item = $t.attr('data-item');
    $('#jobs').attr('data-triple-sort', item)
      // sort column in set direction
    $("#jobs").find("th:contains(corehours)").trigger('sorton', [
      [
        [col, dir]
      ]
    ]);
    // update to current data-direction
    $t.attr('data-direction', (parseInt(dir, 10) + 1) % 2);
    return false;
  });

  function silent_submit(response) {
    console.log(response)
  }

  function submit_and_reload(response) {
    console.log(response)
    location.reload()
  }
  $("#feedback_job_rule").submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), silent_submit)
    return false
  })
  $("#feedback_jobs").submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), silent_submit)
    return false
  })
  $("#feedback_rule").submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), submit_and_reload)
    return false
  })

});


var feedback_started = false;

function toggle_dropdown(target) {
  $(target).toggleClass('show');
}

// open/close new div after job row
function process_response(index, jobid) {
  var row = $("#job_row_" + index);
  var info_row = $("#job_info_" + index);
  if (row.attr('data-info-state') == '-1') {
    return
  }
  if (row.attr('data-info-state') == '0') {
    // open it!
    row.attr('data-info-state', '1');
    //$(info_row).removeClass("hidden_box");
    $(info_row).show();
  } else {
    // close it!
    row.attr('data-info-state', '0');
    //$(info_row).addClass("hidden_box");
    $(info_row).hide();
  }
  //$(info_row).toggleClass("hidden_box");
}

function popup_show(a, b) {
  var x = $("#popup_" + a + "_" + b)
  x.addClass('show')
}

function popup_hide(a, b) {
  var x = $("#popup_" + a + "_" + b)
  x.removeClass('show')
}

// user disagrees with rule
function disagree(jobid, rule) {
  //alert("feedback"+index+" -- "+jobid);
  var form = $("#feedback_job_rule")
  form.find("#user").val(current_user)
  form.find("#account").val(jobs[jobid]['login'])
  form.find("#cluster").val(jobs[jobid]['cluster'])
  form.find("#job_id").val(jobid)
    //FIXME place right task_id (where is it?)
  form.find("#task_id").val(0)
  form.find("#condition").val(rule)
  form.find("#feedback").val($("#question_" + jobid + '_' + rule).val())
  $("#popup_" + jobid + "_" + rule).removeClass('show')
  form.submit()
}

function hide_rule(jobid, rule) {
  var form = $("#feedback_rule")
  form.find("#user").val(current_user)
  form.find("#account").val(jobs[jobid]['login'])
  form.find("#cluster").val(jobs[jobid]['cluster'])
  form.find("#condition").val(rule)
  form.find("#feedback").val($("#question_hide" + jobid + '_' + rule).val())
  form.submit()
}

function intersection(o1, o2) {
  return Object.keys(o1).filter({}.hasOwnProperty.bind(o2));
}

// when job_check (un)checked
function job_check_clicked(jobid){
  var first=true
  var rules={}
  var rules_text=''
  $(".job_check").each(function(){
    if(this.checked==false)
      return
    var jid=$(this).attr('data-job-id')
    if(first){
      rules={}
      //copy rules from first job
      for(var r in jobs[jid]['rules']){
        rules[r]=jobs[jid]['rules'][r]
      }
      first=false
    }
    else{
      //delete rules missed in other selected jobs
      Object.keys(rules).forEach(function(k){
        if(!(k in jobs[jid]['rules']))
          delete rules[k]
      })
    }
  })
  for(r in rules){
    rules_text+="<input type='checkbox' class='disagree_checkbox' data-rule='"+r+"''>"+rules[r]+"</input><br/>"
  }
  if(rules_text==''){
    rules_text='Нет общих правил!!!'
    $('#disagree_button').attr('disabled', true);
  }
  else{
    $('#disagree_button').attr('disabled', false);
  }
  $("#disagree_rules").html(rules_text)
}

// feedback on "O! I disagree with my tasks valuation!"
function multi_job_feedback() {
  // Just start feedback, do preparations
  if (feedback_started == false) {
    var row, c, jobid;
    feedback_started = true;
    // Just prepare feedback - show checkboxes
    $(".job_check").prop('checked',false)
    $(".job_check").show()

    $('#disagree_reason_box').css({
      display: 'inline'
    }).animate();
    $('#disagree_button').text('Отметьте нужные задания и отправьте отзыв').attr('disabled', true);
  } else {
    // all selected, send data!
    var job_list = [];
    var rule_list = [];
    var delimiter = ''
    $('.job_check').each(function(_, el) {
      var e = $(el)
      if (e.prop('checked')) {
        job_list.push(e.attr('data-job-id'))
      }
    })
    
    $('.disagree_checkbox').each(function (_,el) {
      var e = $(el)
      if (e.prop('checked')) {
        rule_list.push(e.attr('data-rule'))
      }
    })

    var feedback={
      'user': current_user,
      'cluster': jobs[job_list[0]]['cluster'],
      'job_id': job_list,
      'condition': rule_list,
      'task_id': 0,
      'class': 1,
      'feedback': $("#disagree_reason").val(),
    }

    $('#disagree_button').text('Отправляем...');
    $('#disagree_button').prop('disabled', true);
    feedback_started = false;
    $.ajax({
      type: "POST",
      url: "feedback",
      data: {'feedback': feedback, 'type': 'multi_jobs'},
    }).done(function( msg ) {
      restore_disagree_button()
    }).fail(function( msg ) {
      restore_disagree_button()
    });

    // var form = $("#feedback_jobs")
    // form.find("#user").val(current_user)
    // form.find("#jobs").val(job_list)
    // form.find("#rules").val(rule_list)
    // form.find("#feedback").val($("#disagree_reason").val())
    // form.submit()
  }
}

function restore_disagree_button() {
    $('#disagree_reason_box').css({
      display: 'none'
    }).animate();

    // Now delete checkboxes
    $(".job_check").hide()
    $('#disagree_button').text('Жмите тут!');
}

function ok_task(jobid) {

}


function agree_all() {
  //var jobs={'job_id':{'login':'l', 'cluster':'c', 'state':'st'},...};
  //
  //  send format:
  //  {user: user_id, feedback: 'text', agree: 1/0,
  //    { job_id: [rule1, rule2, ...],
  //      job_id: [rule1, rule2, ...], ...
  //    }
  //  }
  //  jobs_feedback = {user:int, cluster: string, job_id: int, task_id: int, class=int, feedback=string},{...}
  //  jobs={id: {cluster='..', login='..', state='..'},...}
  var new_feedback=[]
  for (var id in jobs) {
    // search jobs without feedback yet
    if ('feedback' in jobs[id]) {
      //  job has feedback
    } else {
      new_feedback.push({
        'user': current_user,
        'cluster': jobs[id]['cluster'],
        'job_id': id,
        'condition': jobs[id]['rules'],
        'task_id': 0,
        'class': 0,
        'feedback': 'ok!'
      })
    }
  }

  $('#agree_all').prop('disabled', true);

  $.ajax({
    type: "POST",
    url: "feedback",
    data: {'feedback': new_feedback, 'type': 'multi_jobs'},
  }).done(function( msg ) {
    update_jobs_agree(new_feedback)
  }).fail(function( msg ) {
    update_jobs_agree(new_feedback)
  });
}

function update_jobs_agree(feedback){
  //$('.disagree-button').prop('disabled', true);
  $('.agreed-flag').show();
}