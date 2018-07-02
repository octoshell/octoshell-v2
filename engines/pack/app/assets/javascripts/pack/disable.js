function bind_func_disable (enable,disable,item)
{
	function disable_enable_select()
	{
		if  ( $(enable).prop("checked") )
		{
			$(item).prop("disabled",false);
			return;
		}
		if  ( $(disable).prop("checked") )
		{
			$(item).prop("disabled",true);
		}
	};
	disable_enable_select();
	$(enable).change(disable_enable_select);
	$(disable).change(disable_enable_select);
};
