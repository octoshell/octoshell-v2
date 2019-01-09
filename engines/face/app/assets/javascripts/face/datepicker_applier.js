

$(function(){
  $.fn.datepicker.dates['en']['format'] = 'yyyy.mm.dd';
  $.fn.datepicker.dates['ru']['format'] = 'yyyy.mm.dd';
  $.fn.datepicker.defaults.language = window.locale;
  $.fn.datepicker.defaults.autoclose = true;
  $(".datepicker").datepicker();
});
