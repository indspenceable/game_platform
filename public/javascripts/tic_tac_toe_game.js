var SQUARE_WIDTH = 32;
var SQUARE_HEIGHT = 32;

var current_turn;
var player_name;

function drawBoard() {
  var context = document.getElementById("canvas").getContext("2d");
  for (var i = 0; i < map.length; i++ ) {
    for (var j = 0; j < map[i].length; j++ ) {
      if (map[i][j] != null) {
        var p = map[i][j]
        if (p == player_name) {
          context.fillStyle = "#F00"
        } else {
          context.fillStyle = "#00F"
        }
        context.fillRect(i * SQUARE_WIDTH, j*SQUARE_HEIGHT, SQUARE_WIDTH, SQUARE_HEIGHT);
      }
    }
  }
}

function getCursorPosition(e) {
  var x;
  var y;
  var gCanvasElement = document.getElementById("canvas");
  if (e.pageX != undefined && e.pageY != undefined) {
    x = e.pageX;
    y = e.pageY;
  } else {
    x = e.clientX + document.body.scrollLeft +
      document.documentElement.scrollLeft;
    y = e.clientY + document.body.scrollTop +
      document.documentElement.scrollTop;
  }
  x -= gCanvasElement.offsetLeft;
  y -= gCanvasElement.offsetTop;
  return [x,y];
}

function getCursorSquare(e) {
  var cp = getCursorPosition(e);
  return [Math.floor(cp[0]/SQUARE_WIDTH),Math.floor(cp[1]/SQUARE_HEIGHT)];
}

function canvasClickEvent(e) {
  if (!myTurn()) {
    // Do nothing!
    alert("it's not your turn");
    //Maybe we can select units to see them in detail
  } else {
    var loc = getCursorSquare(e)
    var x = loc[0]
    var y = loc[1]
    if (board[x][y] == null) {
      $.post("/submit",{'type':'play','loc':loc}, function(response) {})
    } else {
      alert("You can't play a square that already exists.");
    }
  }
}

function update() {
  if (!myTurn()) {
    $.get("/transitions",current_state, function(response) {
      if (response.length > 0) {
        for (var i = 0; i < response.length; i++ ) {
          processTransition(response[i]);
        }
      }
    });
  }
  drawBoard();
}

function processTransition(t) {
  if (t.type == 'play_square') {
    map[t.x][t.y] = t.player
    current_turn = t.next_turn
  } else if (t.type == 'game_over') {
    alert("The game is over.");
  }
}

$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});
$(document).ready(function() {
  $('#canvas').click(function(e) {
    canvasClickEvent(e);
  });
  update();
});

