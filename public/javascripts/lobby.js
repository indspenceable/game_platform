function update() {
  console.log("before poll.")
  $.get("/poll_lobby",function(response) {
    console.log("Got poll.",response)
    $('#games').html(response.games);

  })
}

$(document).ready(function() {
  //Join Game button
  $("#join_game_button").click(function() {
    $.post("/challenge",{targets:$("#challenge").val(),game_type:'DungeonClash'},function(response) {
      console.log("issued challenge.", response) 
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
