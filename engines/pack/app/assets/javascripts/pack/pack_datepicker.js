
 $(document).on('focus',".my_datepicker", function(){
    $(this).datepicker({
  dateFormat: 'mm-dd-yy',
  minDate: new Date(),
  
});
});

