var game_id;

function update() {
  var context = document.getElementById("canvas").getContext("2d");
  console.log("Getting Deltas.", current_turn, game_id);
  $.get("/deltas",{'game_id':game_id,'current_turn':current_turn},function(response) {
    if (response['game_over'] != null) {
      $("#nav").html('<a href="/">Go home</a>');
    } 
    if (response.deltas.length > 0) {
      for (var i = 0; i < response.deltas.length; i++ ) {
        //Plugin with the processDeltas method
        processDelta(response.deltas[i]);
      }
      // Plugin with the drawGame() method
      drawGame(context);
    }
  });
  // Plugin with the drawGame() method
  drawGame(context);
}

$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

$(document).ready(function() {
  $("#quit").click(function(e) {
    $.post("/quit")
  })
  $.get('/state',{'game_id':game_id}, function(data) {
    //game_id = data['game_id'];
    // Plugin with the "load_state_json" method
    load_state_json(data['state']);
    $('#canvas').click(function(e) {
      //Plugin with the "canvasClickEvent" method
      canvasClickEvent(e);
    });
    setInterval("update();",3000);
    update();
  });
});

