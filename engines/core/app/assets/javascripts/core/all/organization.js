function remove_extra_spaces(){
  $(document).on('change',"textarea, input[type='text']",function(e){
    var current_val =  $(this).val();
    current_val = current_val.replace(/(\s){2,}/g,' ')
                             .replace(/^\s/g,'')
                             .replace(/\s$/g,'');
    $(this).val(current_val);
  });
}

function getJSONSync(url,success)
{
  $.ajax({
    dataType: "json",
    url: url,
    success: success,
    async: false
  });
}
