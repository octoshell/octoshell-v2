$(function(){
  // mark hidden rules
  filters.forEach(function(rule){
    $("#btn-hide-"+rule).addClass("tinted")
  })
  // mark disabled email notifications
  emails.forEach(function(rule){
    $("#btn-email-"+rule).addClass("tinted")
  })
})

// new rule suggestion
function all_send_suggestion(){
  var feedback={
    cluster: 'all',
    user: current_user,
    feedback: $("#suggest_new_rule_text").val(),
  }
  $.ajax({
    type: "POST",
    url: "feedback",
    data: {'feedback': feedback, 'type': 'proposal'},
  })
}

function all_pre_hide_rule(rule_id) {
  var i=filters.indexOf(rule_id)
  if(i>-1){
    // already filtered! Unfilter it!!!
    filters.splice(i,1)
    all_hide_rule(rule_id,true)
  }
  else{
    // open confirmation dialog
    $("#hide_rule_"+rule_id).addClass('target')
  }
}

function all_hide_rule(rule_id,del) {
  var feedback={
    user: current_user,
    condition: rule_id,
    cluster: 'all',
    delete: (del ? 1 : 0),
    feedback: $("#text_hide_rule_"+rule_id).val(),
  }
  filters.push(rule_id)
  if(del){
    $("#btn-hide-"+rule_id).removeClass("tinted")
  }
  else{
    $("#btn-hide-"+rule_id).addClass("tinted")
  }
  $("#hide_rule_"+rule_id).removeClass('target')

  $.ajax({
    type: "POST",
    url: "feedback",
    data: {'feedback': feedback, 'type': 'hide_rule'},
  })
}

function all_pre_email_rule(rule_id) {
  var i=emails.indexOf(rule_id)
  if(i>-1){
    // already disabled! Enable it!!!
    emails.splice(i,1)
    all_email_rule(rule_id,true)
  }
  else{
    // open confirmation dialog
    $("#email_rule_"+rule_id).addClass('target')
  }
}

function all_email_rule(rule_id,del) {
  var feedback={
    user: current_user,
    condition: rule_id,
    delete: (del ? 1 : 0),
  }
  emails.push(rule_id)
  if(del){
    $("#btn-email-"+rule_id).removeClass("tinted")
  }
  else{
    $("#btn-email-"+rule_id).addClass("tinted")
  }
  $("#email_rule_"+rule_id).removeClass('target')

  $.ajax({
    type: "POST",
    url: "feedback",
    data: {'feedback': feedback, 'type': 'email_rule'},
  })
}

function all_pre_feedback_rule(rule_id) {
  $("#feedback_rule_"+rule_id).addClass('target')
}

function all_feedback_rule(rule_id) {
  var feedback={
    user: current_user,
    condition: rule_id,
    feedback: $('#text_feedback_rule_'+rule_id).val()
  }
  $("#feedback_rule_"+rule_id).removeClass('target')

  $.ajax({
    type: "POST",
    url: "feedback",
    data: {'feedback': feedback, 'type': 'feedback_rule'},
  })
}

