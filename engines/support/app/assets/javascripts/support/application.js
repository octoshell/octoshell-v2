// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

$(document).ready(function(){
  $('#reply_template').on('change', function(){
    $('#reply_message').val($(this).val())
  });

  $(document).on('reload_form form', function(e){
    var form = $(e.target)
    $.get(form.data('reload-url'), function(data){
      form.replaceWith(data)
    })
  });

  $(document)
    .on('ajax:success #new_ticket_tag', function(e, data, xhr){
      $('#tags_form').trigger('reload_form')
    })
    .on('ajax:beforeSend #new_ticket_tag', function(e){
      $(e.target).find(':input').each(function(i, e){
        e.disabled = true
      })
    })
    .on('ajax:complete #new_ticket_tag', function(e){
      $(e.target).find(':input').each(function(i, e){
        if (e.type != 'submit') {
          e.value = ""
        }
        e.disabled = false
      })
    })

  $('div.toggle-box').on('click > div.toggle', function(e){
    var box = $(e.target).parents('div.toggle-box:first')
    box.find('> div.object').toggle()
  })

  $('#reply-template-maker').on('click', function(e){
    var data = $('#reply_message').val();
    var url = $('#reply-template-maker').attr("href") + '?' + 'reply_template[message]=' + data;
    window.open(url, '_blank')
    return false
  })
});
