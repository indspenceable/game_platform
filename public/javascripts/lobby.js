function update() {
  $.get("/poll_lobby",function(response) {
    if (response['in_game'] == true) {
      window.location = '/game/'
    } else {
      //for (var i = 0; i < response['players'].length; i++) {
        //TODO make this part work.
      //}
    }
  });
}
$(document).ready(function() {
  //$("#set_name_input").val("<%= session[:name] %>");
  $("#join_game_button").click( function() {
    $.post('game/new',{'targets':$("#challenge").val()},function(data) {
      if (data) {
        window.location = '/game/' 
      } else {
        $("#game_response").text("Unable to create a game.");
      }
    });
  });
  setInterval("update();",3000);
  update();
});
$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});
