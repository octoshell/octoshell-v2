$(function(){

	$('textarea.markdown-edit').each(function(i, e){
    var elem = $(e);
		var data_bar = elem.parents('.markdownlive-container').find('.markdownlive-bar');
		var data_preview = elem.parents('.markdownlive-container').find('.markdownlive-preview');
		elem.markdownlive({'data-bar': data_bar,'data-preview': data_preview });
	});

});
