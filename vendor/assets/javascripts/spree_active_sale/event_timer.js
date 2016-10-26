$(document).ready(function() {
  $("[data-timer]").each(function() {
    var cTime = $(this).attr('data-timer');
    var timeLayout = $(this).attr('data-layout');
    $(this).countdown({
      until: cTime,
      compact: true,
      layout: timeLayout
    });
  });
});
