// Альтернативная версия с регулярным выражением
// function setFormFieldsWidth(selector, klass) {
//   const allLabels = document.querySelectorAll(selector);
//   const gridClassRegex = /^col-(xs|sm|md|lg|xl)-(\d{1,2})$/;

//   allLabels.forEach(label => {
//     // Удаляем классы, соответствующие шаблону col-*-*
//     Array.from(label.classList).forEach(className => {
//       if (gridClassRegex.test(className)) {
//         label.classList.remove(className);
//       }
//     });

//     label.classList.add(klass);
//   });
// }

// // Для обычных страниц
// document.addEventListener('DOMContentLoaded', () => {
//   setFormFieldsWidth('div.fix-labels > label', 'col-sm-6');
//   setFormFieldsWidth('div.fix-labels > div', 'col-sm-6');
// });
$(document).on('nested:fieldAdded', function(event){
  // this field was just inserted into your form
  // var field = event.field;
  // // it's a jQuery object already! Now you can find date input
  // var dateField = field.find('.date');
  // // and activate datepicker on it
  // dateField.datepicker();

  $(function(){
    $.fn.datepicker.dates['en']['format'] = 'yyyy.mm.dd';
    $.fn.datepicker.dates['ru']['format'] = 'yyyy.mm.dd';
    $.fn.datepicker.defaults.language = window.locale;
    $.fn.datepicker.defaults.autoclose = true;
    $(".datepicker").datepicker();
  });

});