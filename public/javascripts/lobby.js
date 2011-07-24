function update() {
  $.get("/poll_lobby",function(response) {
    if ('redirect' in response) {
      window.location = '/' + response['redirect']
    } else {
      var new_player_list = ""
      for (var i =0; i < response['players'].length; i++) {
        new_player_list += ('<br/>' + response['players'][i]);
      }
      $("#players:first").html(new_player_list);
    }
  });
}
var players;

$(document).ready(function() {
  //Join Game button
  $("#join_game_button").click(function() {
    $.post('game/new',{'targets':$("#challenge").val()},function(data) {
      if (data['success']) {
        window.location = '/game/' +data['game_id']
      } else {
        $("#game_response").text("Unable to create a game.");
      }
    });
  });
  //Set up automatic updating
  setInterval("update();",5000);
  update();
});
$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});
