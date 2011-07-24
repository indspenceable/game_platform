var SQUARE_WIDTH = 100; var SQUARE_HEIGHT = 100;

var current_player;
var current_turn;
var player_name;
var board;

function myTurn() {
  console.log(player_name,current_player);
  return (player_name == current_player);
}

function drawGame(context) {
  for (var i = 0; i < board.length; i++ ) {
    for (var j = 0; j < board[i].length; j++ ) {
      if (board[i][j] != null) {
        var p = board[i][j]
        if (p == player_name) {
          context.fillStyle = "#F00"
        } else {
          context.fillStyle = "#00F"
        }
        context.fillRect(i * SQUARE_WIDTH, j*SQUARE_HEIGHT, SQUARE_WIDTH, SQUARE_HEIGHT);
      }
      context.fillStyle = "#000"
      context.fillRect(i * SQUARE_WIDTH, j*SQUARE_HEIGHT, 10, 10);
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
      $.post("/submit",{'type':'play','loc':loc}, function(response) {
        console.log("submitted order, updating.");
        update();
      })
    } else {
      alert("You can't play a square that already exists.");
    }
  }
}


function processTransitions(d) {
  if (d.type == 'play_square') {
    board[d.x][d.y] = d.player
    current_player = d.next_player
    current_turn = d.next_turn
  } 
}

function load_state_json(data) {
  player_name = data['name'];
  current_player = data['current_player'];
  current_turn = data['current_turn'];
  board = data['board'];
}

