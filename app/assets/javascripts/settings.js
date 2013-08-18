 $(document).ready(function() {
     $('.edit').editable('//www.argu.nl/settings/', {
     	tooltip		: 'Click to edit',
     	submit		: 'Save',
     	indicator	: 'Saving..',
     	onblur		: 'cancel',
     	style		: 'white-space: nowrap;'
     });
     $('.edit_area').editable('//www.argu.nl/settings', { 
        type      : 'textarea',
        submit    : 'Save',
        indicator : 'Saving..',
        onblur	  : 'cancel',
        tooltip   : 'Click to edit'
     });
 });