function getDate(dateString)
{
  var endLicArr = dateString.split('-');
  var date = new Date(endLicArr[0],endLicArr[1],endLicArr[2]);
  date = date.setHours(0,0,0,0);
  return date;
}

function getAmericanDate(dateString)
{
  var endLicArr = dateString.split('-');
  var date = new Date(endLicArr[2],endLicArr[0],endLicArr[1]);
  date = date.setHours(0,0,0,0);
  return date;
}


 $(document).on('focus',".my_datepicker", function(){

    $(this).datepicker({
  dateFormat: 'mm-dd-yy',
  minDate: 0

});
});
