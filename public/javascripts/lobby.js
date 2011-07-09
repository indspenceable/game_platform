$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});
$(document).ready(function() {
  //$("#set_name_input").val("<%= session[:name] %>");
  $("#set_name_button").click( function() {
    $.post('name',{'name': $("#set_name_input").val()},function(data) {
      if (data) {
        $("#name_response").text("Name changed successfully.");
      } else {
        $("#name_response").text("unable to change name.");
      }
    });
  });
  $("#join_game_button").click( function() {
    $.post('game/new',function(data) {
      if (data) {
        window.location = '/game/' 
      } else {
        $("#game_response").text("Unable to create a game.");
      }
    });
  });
});
