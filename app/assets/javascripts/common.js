jQuery(function ($) {

	$(function(){
		$('html').removeClass('no-js');
	}());
	
	$(function(){
		$('.i-wrapper').css('min-height', $('html').height());
	}());

});

function draw(n, m, el, d) {
	var d = d || 10;  /* factor */
	var max_mn = 12;
	var max = Math.max(n, m);
	if (max > max_mn) {
		if (n > m) {
			m = parseInt(m * max_mn / n);
			n = max_mn;
		} else {
			n = parseInt(n * max_mn / m);
			m = max_mn;
		}
	}
	var elem = document.getElementById(el);
	if (!elem || !elem.getContext) return;
	var context = elem.getContext('2d');
	if (!context) return;
	context.lineWidth = 1;
	context.strokeStyle = '#fff';
	n = Math.sqrt(n) * d;
	m = Math.sqrt(m) * d;
	if (m * n > 0) {
		var x = (n + m) / 2,
			dn = n * 11 / 20,
			dm = m * 11 / 20,
			hn = hm = 0;

		if (n > m) hm = n - m;
		if (m > n) hn = m - n;
		
		context.fillStyle   = '#0077cb';
		context.beginPath();
		context.moveTo(2.5 * n, n + hn);
		context.bezierCurveTo(2.5 * n, n + hn, n + dn, hn, n, hn);
		context.bezierCurveTo(n - dn, hn, 0, n - dn + hn, 0, n + hn);
		context.bezierCurveTo(0, n + dn + hn, n - dn, 2 * n + hn, n, 2 * n + hn);
		context.bezierCurveTo(n + dn, 2 * n + hn, 2.5 * n, n + hn, 2.5 * n, n + hn);
		context.stroke();
		context.fill();
		context.closePath();

		context.fillStyle   = '#df2a00';
		context.beginPath();
		context.moveTo(2.5 * n, n + hn);
		context.bezierCurveTo(2.5 * n, n + hn, 2 * n + m + x - dm, hm, 2 * n + m + x, hm);
		context.bezierCurveTo(2 * n + m + x + dm, hm, 2 * n + 2 * m + x, m + hm - dm, 2 * n + 2 * m + x, m + hm);
		context.bezierCurveTo(2 * n + 2 * m + x, m + hm + dm, 2 * n + m + x + dm, 2 * m + hm, 2 * n + m + x, 2 * m + hm);
		context.bezierCurveTo(2 * n + m + x - dm, 2 * m + hm, 2.5 * n, n + hn, 2.5 * n, n + hn);
		context.stroke();
		context.fill();
		context.closePath();
	} else {
		if (n == 0) {
			context.fillStyle   = '#df2a00';
			n = m;
		} else {
			context.fillStyle   = '#0077cb';
		}
		context.beginPath();
		context.arc(n, n, n, 0, 360, false);
		context.stroke();
		context.fill();
		context.closePath();
	}
}
