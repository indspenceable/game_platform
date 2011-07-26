var players = [];
var challenges = [];
var current_game_id = "";

function remove(list,item){
  for (var i = 0; i < list.length; i++ ) {
    if (list[i] == item) {
      return list.splice(i,1);
    }
  }
  return list;
}

function removePlayer(pl_name) {
  remove(players,pl_name);
  $("#players").remove("#player_"+pl_name);
}

function addPlayer(pl_name) {
  players.push(pl_name);
  $("#players").append($('<div/>', {
    id:'player_'+pl_name,
    text:pl_name
  })).append($('<input/>', {
    type:'button',
    id:'challenge_'+pl_name,
    value:'challenge '+pl_name,
  }));
  $('#challenge_'+pl_name).click(function(e) {
    $.post('/challenge',{target:pl_name},function(response) {
      $("#messages").append("You challenged " + pl_name + "\n");
    });
  });
}

function addChallenge(pl_name) {
  challenges.push(pl_name);
  $("#player_"+pl_name).append($('<input/>', {
    type:'button',
    id:'accept_'+pl_name,
    value:'Accept challenge from '+pl_name,
  }))
  $("#accept_"+pl_name).click(function(e) {
    $("#messages").append("You are accepting " + pl_name);
    $.post('/accept',{target:pl_name},function(response) { });
  });
}
function removeChallenge(pl_name) {
  remove(challenges,pl_name);
  $("#challenges").remove("#challenge_"+pl_name)
  $("#accept_"+pl_name).remove()
}

function update() {
  obj = {players:players, challenges:challenges}
  $.get("/poll_lobby",obj,function(response) {
    if (response['redirect'] != '') {
        window.location = response['redirect']
    }

    for (var i =0; i < response['add_player'].length; i++) {
      addPlayer(response['add_player'][i]);
    }
    for (var i =0; i < response['remove_player'].length; i++) {
      removePlayer(response['remove_player'][i]);
    }
    for (var i = 0; i < response['challenge'].length; i++ ) {
      addChallenge(response['challenge'][i])
    }
    for (var i = 0; i < response['unchallenge'].length; i++ ) {
      removeChallenge(response['unchallenge'][i])
    }
  });
}

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
