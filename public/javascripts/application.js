function processPreloadedText(field, event, defaultText)
{
	if(event == 'onfocus')
	{
		if(field.value == defaultText)
		{
			field.value = '';
			field.removeClassName('inactive_preloaded_field');
			field.addClassName('active_preloaded_field');
		}
	}
	else if(event == 'onblur')
	{
		if(field.value == '')
		{
			field.value = defaultText;
			field.addClassName('inactive_preloaded_field');
			field.removeClassName('active_preloaded_field');
		}
	}
}