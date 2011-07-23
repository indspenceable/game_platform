function update() {
  $.get("/poll_lobby",function(response) {
  });
}


$(document).ready(function() {
  $("#join_game_button").click(function() {
    $.post('game/new',{'targets':$("#challenge").val()},function(data) {
      if (data['success']) {
        console.log("Data is " + data['game_id'])
        window.location = '/game/' +data['game_id']
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
