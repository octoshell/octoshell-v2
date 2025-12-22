// Альтернативная версия с регулярным выражением
function setFormFieldsWidth(selector, klass) {
  const allLabels = document.querySelectorAll(selector);
  const gridClassRegex = /^col-(xs|sm|md|lg|xl)-(\d{1,2})$/;

  allLabels.forEach(label => {
    // Удаляем классы, соответствующие шаблону col-*-*
    Array.from(label.classList).forEach(className => {
      if (gridClassRegex.test(className)) {
        label.classList.remove(className);
      }
    });

    label.classList.add(klass);
  });
}

// Для обычных страниц
document.addEventListener('DOMContentLoaded', () => {
  setFormFieldsWidth('div.fix-labels > label', 'col-sm-8');
  setFormFieldsWidth('div.fix-labels > div', 'col-sm-4');
});
