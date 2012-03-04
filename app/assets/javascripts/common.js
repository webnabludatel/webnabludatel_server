jQuery(function ($) {

	$(function(){
		$('html').removeClass('no-js');
	}());
	
	$(function(){
		$('.i-wrapper').css('min-height', $('html').height());
	}());

});

function draw(left_size, right_size, element, zoom_factor) {

  /* prepare context */

  var left_color = '#0077cb';
  var right_color = '#df2a00';
  var elem = document.getElementById(element);
  if (!elem || !elem.getContext) return;

  var context = elem.getContext('2d');
  if (!context) return;
  context.lineWidth = 1;
  context.strokeStyle = '#fff';

  var normalization_factor = 12 / Math.max(left_size, right_size);

	if (normalization_factor < 1) {
    right_size *= normalization_factor;
    left_size *= normalization_factor
	}

  zoom_factor = zoom_factor || 10;
  left_size = Math.sqrt(left_size) * zoom_factor;
	right_size = Math.sqrt(right_size) * zoom_factor;

  if (right_size * left_size > 0) {
		var x = (left_size + right_size) / 2,
			  dn = left_size * 11 / 20,
			  dm = right_size * 11 / 20,
			  hn = 0,
        hm = 0;

		if (left_size > right_size) hm = left_size - right_size;
		if (right_size > left_size) hn = right_size - left_size;
		
		context.fillStyle   = left_color;
		context.beginPath();
		context.moveTo(2.5 * left_size, left_size + hn);
		context.bezierCurveTo(2.5 * left_size, left_size + hn, left_size + dn, hn, left_size, hn);
		context.bezierCurveTo(left_size - dn, hn, 0, left_size - dn + hn, 0, left_size + hn);
		context.bezierCurveTo(0, left_size + dn + hn, left_size - dn, 2 * left_size + hn, left_size, 2 * left_size + hn);
		context.bezierCurveTo(left_size + dn, 2 * left_size + hn, 2.5 * left_size, left_size + hn, 2.5 * left_size, left_size + hn);
		context.stroke();
		context.fill();
		context.closePath();

		context.fillStyle   = right_color;
		context.beginPath();
		context.moveTo(2.5 * left_size, left_size + hn);
		context.bezierCurveTo(2.5 * left_size, left_size + hn, 2 * left_size + right_size + x - dm, hm, 2 * left_size + right_size + x, hm);
		context.bezierCurveTo(2 * left_size + right_size + x + dm, hm, 2 * left_size + 2 * right_size + x, right_size + hm - dm, 2 * left_size + 2 * right_size + x, right_size + hm);
		context.bezierCurveTo(2 * left_size + 2 * right_size + x, right_size + hm + dm, 2 * left_size + right_size + x + dm, 2 * right_size + hm, 2 * left_size + right_size + x, 2 * right_size + hm);
		context.bezierCurveTo(2 * left_size + right_size + x - dm, 2 * right_size + hm, 2.5 * left_size, left_size + hn, 2.5 * left_size, left_size + hn);
		context.stroke();
		context.fill();
		context.closePath();
	} else {
		if (left_size == 0) {
			context.fillStyle   = right_color;
			left_size = right_size;
		} else {
			context.fillStyle   = left_color;
		}
		context.beginPath();
		context.arc(left_size, left_size, left_size, 0, 360, false);
		context.stroke();
		context.fill();
		context.closePath();
	}
}
