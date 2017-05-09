//Нужно для того,чтобы поля формы не сбрасывались после отправки
$(function ()
{

  $(`form.ajax-form`).submit(function(event) {
  
    
    
    var msg   = $(this).serialize();
        $.ajax({
          type: 'GET',
          dataType: 'script',
          url: $(this).attr('action'),

          data: msg
         
          
          
        });
 
    
    return false;

  });
});
