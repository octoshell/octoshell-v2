function getDate(dateString,delim = '.')
{
  var endLicArr = dateString.split(delim);
  for(var i=0;i<3;i++)
  {
    endLicArr[i] = parseInt(endLicArr[i]);
  }
  endLicArr[1] = endLicArr[1] - 1;
  var date = new Date(endLicArr[0],endLicArr[1],endLicArr[2]);
  date.setHours(0,0,0,0);
  return date;
}
