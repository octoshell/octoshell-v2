(function( $ ) {
  $.fn.ruTwbsPagination = function(params) {
		locale = {
			first: 'Начало',
			next: 'Следующая',
			prev: 'Предыдущая',
			last: 'Конец'
		}
		for (var attrname in locale) { params[attrname] = locale[attrname]; }
		this.twbsPagination(params);
  };
})(jQuery);
