//var current_state,current_turn; player_name;
var SQUARE_WIDTH = 32;
var SQUARE_HEIGHT = 32;


//Globals
var selected_action = null;
var selected_unit = null;

//EXAMPLE map
var map = []//[[null,null,null,null,null,null],[null,null,{'movespeed':3,'loc':[1,2],'unit_id':1}],[null,null,null]];
for (var z = 0; z < 10; z++ ) {
  var new_array = []
  for (var y = 0; y < 10; y++ ) {
    new_array.push(null);
  }
  map.push(new_array);
}
function mapWidth() {
  return map.length
}
function mapHeight() {
  return map[0].length
}
map[1][6] = {'movespeed':3,'loc':[1,6],'unit_id':1};


function unitAt(loc) {
  var x = loc[0];
  var y = loc[1];
  return map[x][y];
}


function selectUnit(unit) {
  selected_unit = unit;
  if (selected_unit != null) {
    console.log("Selected a unit.");
  }
  //TODO maybe make it show up in an inspector
  //ALso, set some state to show if we own this unit?
}

//TODO fix this shit.
function myTurn() {
  return true;
}

//Used for getting the location on the canvas of the cursor
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

function locationIncluded(item,ary) {
  for ( var i = 0; i < ary.length; i++ ) {
    if (ary[i].compareArrays(item)) {
      return i;
    }
  }
  return -1;
}

Array.prototype.compareArrays = function(arr) {
  if (this.length != arr.length) return false;
  for (var i = 0; i < arr.length; i++) {
    if (this[i].compareArrays) { //likely nested array
      if (!this[i].compareArrays(arr[i])) return false;
      else continue;
    }
    if (this[i] != arr[i]) return false;
  }
  return true;
}

//Bredth-first search. Maybe optimize this later.
function findPath(start,end) {
  var open_list = [[start]]
  var closed_list = []

  //While there is another vertex to visit
  while (open_list.length > 0) {
    current = open_list.shift()
    current_loc = current[current.length-1]
    console.log("Current_loc is ",current_loc);
    closed_list.push(current_loc);

    // if this is the destination, then return the path.
    if (current_loc.compareArrays(end)) {
      alert(current);
      return current;
    }


    //Otherwise, look at neighbors
    for (var a = -1; a < 2; a++) {
      for (var b = -1; b < 2; b++) {
        //ensure we are still on the map, we are looking at a square one
        // distance away.
        if ((current_loc[0]+a >= 0) && (current_loc[0]+a < mapWidth()) && (current_loc[1]+b >= 0) && (current_loc[1]+b < mapHeight())) {
          if ((( a==0 ) || (b==0)) && (a != b)) {
            var new_loc = [current_loc[0]+a, current_loc[1]+b];
            // If we haven't already seen this one
            if (locationIncluded(new_loc,closed_list) == -1 ||
            locationIncluded(new_loc,open_list)) {
              var adder = current.slice(0)
              adder.push(new_loc);
              console.log("adding to open_list",new_loc);
              open_list.push(adder);
            }
          }
        }
      }
    }
  }
  return null;
}

function createMovementAction(unit,loc) {
  path = findPath(unit.loc,loc);
  rtn = {}
  rtn.type = 'movement';
  rtn.path = path;
  rtn.valid_targets = [path[path.length]];
  console.log("Valid targets is",rtn.valid_targets);
  rtn.unit = unit.unit_id
  return rtn;
}

function inMovementRange(unit, loc) {
  path = findPath(unit.loc, loc);
  console.log("Path is:",path); 
  alert("ok, breathing room.");
  return (path && path.length < unit.move_speed);
}

function validTarget(action, loc) {
  return (locationIncluded(loc,action.valid_targets) != -1);
}

function applyAction(action,loc) {
  action.loc = loc;
  console.log("Apply action: " + action);
}

function canvasClickEvent(e) {
  if (!myTurn()) {
    // Do nothing!
    alert("it's not your turn");
    //Maybe we can select units to see them in detail
  } else {
    // it is my turn...
    var loc = getCursorSquare(e)
    console.log("Clicked on loc" + loc)
    if (selected_action) {
      if (validTarget(action,loc)) {
        //This should just call ajax stuff.
        //applyAction(action,loc);
      } else {
        select_action = null;
      }
    } else {
      if (selected_unit && inMovementRange(selected_unit,loc)) {
        selected_action = create_move_action(selected_unit,loc);
      } else {
        selectUnit(unitAt(loc));
      }
    }
  }
}

function drawCanvas() {
  var context = document.getElementById("canvas").getContext("2d");
  for (var i = 0; i < map.length; i++ ) {
    for (var j = 0; j < map[i].length; j++ ) {
      if (map[i][j] != null) {
        context.fillRect(i * SQUARE_WIDTH, j*SQUARE_HEIGHT, SQUARE_WIDTH, SQUARE_HEIGHT);
      }
    }
  }
}

function update() {
  drawCanvas();
  if (!myTurn()) {
    // Poll for any transitions        
    $.get("/transitions",current_state, function(response) {
      if (response.length > 0) {
        for (var i = 0; i < response.length; i++ ) {
          process_transition(response[i]);
        }
      }
    });
  }
  setTimeout(function() {
    update(); 
  },3000);
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

