var game_id;
var current_turn;
var auto_advance = true;
var player_name;

function attemptToAdvanceState() {
  var context = document.getElementById("canvas").getContext("2d");
  $.get("/deltas",{'game_id':game_id,'turn_id':current_turn,'player':player_name},function(response) {
    if (response.success == true) {
      processDelta(response.delta);
      //current_turn response.meta;
      drawGame(context);
    }
  });
}

function update() {
  if (auto_advance==true) {
    attemptToAdvanceState();
  }
}

$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

function loadMeta(data) {
  current_turn = data.turn_number
}

function submitMove(move) {
  $.post("/submit",{'player':player_name,'game_id':game_id,'turn_id':current_turn,'move':move}, function(response) {
    update();
  })
}

$(document).ready(function() {
  //TODO - can the player quit the game at any point?
  $("#quit").click(function(e) {
    $.post("/quit")
  })

  $.get('/state',{'game_id':game_id}, function(data) {
    if (data['success'] == true) {
      // Plug into the "load_state" method
      loadMeta(data['meta'])
      loadState(data['state']);
      $('#canvas').click(function(e) {
        //Plug into the "canvasClickEvent" method
        canvasClickEvent(e);
      });
      setInterval("update();",1000);
      update();
      drawGame(document.getElementById("canvas").getContext("2d"))
    } else {
      alert("Error retrieving game state.");
      console.log(data['error'])
    }
  });
});

