function find_by_id (array, value) {
    for (var i = 0; i < array.length; i++) {
      if (array[i].id === value) return i;
    }

    return -1;
}

function execute_after_send(form_selector,func = function(){})
{
  $(form_selector).submit(function(event) {
    var msg   = $(this).serialize();
        $.ajax({
          type: 'POST',
          dataType: 'script',
          url: $(this).attr('action'),
          data: msg,
          success: func
        });
    return false;
  });
}
