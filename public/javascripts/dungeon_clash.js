var SQUARE_WIDTH = 10; var SQUARE_HEIGHT = 10;

var current_player;
var board;

function loadState(data) {
  map = data['map'];
  //var context = document.getElementById("canvas").getContext("2d");
  $("#canvas").width("620");
}

function drawGame(context) {
  for (var i = 0; i < map.length; i++ ) {
    for (var j = 0; j < map[i].length; j++ ) {
      if (map[i][j] == 'empty') {
        context.fillStyle = "#F00"
      } else {
        context.fillStyle = "#F0F"
      }
      context.fillRect(i * SQUARE_WIDTH, j*SQUARE_HEIGHT, SQUARE_WIDTH, SQUARE_HEIGHT);
    }
  }
}
