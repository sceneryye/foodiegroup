	// implementation of disabled form fields
	// $('.datetimepicker').fdatetimepicker({
 //    language: 'zh'
 //  });

	$(document).ready(function(){
  $('.new-event').find('input').each(function(){
  	if(($(this).val()=='0' || $(this).val()=='0.0') && location.pathname.split('/')[2] == 'new'){
  		$(this).val('');
  	}
  });
});

	var nowTemp = new Date();
	var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
	var checkin = $('#dpd1').fdatetimepicker({
		onRender: function (date) {
			return date.valueOf() < now.valueOf() ? 'disabled' : '';
		}
	}).on('changeDate', function (ev) {
		if (ev.date.valueOf() > checkout.date.valueOf()) {
			var newDate = new Date(ev.date)
			newDate.setDate(newDate.getDate() + 1);
			checkout.update(newDate);
		}
		checkin.hide();
		$('#dpd2')[0].focus();
	}).data('datepicker');
	var checkout = $('#dpd2').fdatetimepicker({
		onRender: function (date) {
			return date.valueOf() <= checkin.date.valueOf() ? 'disabled' : '';
		}
	}).on('changeDate', function (ev) {
		checkout.hide();
	}).data('datepicker');

	//--------调用微信支付---------
	$('.wc-pay').on("click", function(){
		$('form .pay-form').submit();
	})