$('#lang-pref a').click(function(e){
	e.preventDefault();
	var lang = $(this).attr('lang');
	$('<form action="#{main_app.change_lang_prefs_path}" method="POST"/>')
			.append($('<input type="hidden" name="language" value="' + lang + '">'))
			.append($('<input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">'))
			.appendTo($(document.body))
			.submit();
});
