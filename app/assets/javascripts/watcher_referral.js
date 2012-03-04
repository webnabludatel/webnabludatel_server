$(document).ready(function() {
    $('.watcher_referral_action').bind('click', function() {
      var action = $(this).data('action');
      $(this).parent().parent().find('.approve').css('display', 'none')
      $(this).parent().parent().find('.reject').css('display', 'none')
      $(this).parent().parent().find('.problem').css('display', 'none')
      $(this).parent().parent().find('.' + action).css('display', 'block')
    });
});
