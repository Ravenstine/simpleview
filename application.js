(function(){

  var stream = new WebSocket('ws://' + window.location.hostname + ':9393' + "?channel=gimpler")
  var imageElement = document.querySelector("img")

  stream.onopen = function(){
    console.log('connection open')
  }

  stream.onclose = function(){
    console.log('connection closed')
  }

  stream.onmessage = function(e){
    console.log('received image')
    imageElement.src = "data:image/jpg;base64," + e.data
  }

  function sendEvent(event, data){
    var data, message
    data = {event: event, data: data}
    message = JSON.stringify(data)
    stream.send(message)
  }

  function addEventListeners(events, callback){
    var i = 0
    while(i < events.length){
      (function(){
        var event = events[i]
        document.body.addEventListener(event, function(e){
          callback(e, event)
        })
      })()
      i++
    } 
  }

  function addPushers(events, callback){
    addEventListeners(events, function(e, event){
      sendEvent(event, callback(e, event))
    })
  }

  addPushers(["mouseup", "mousedown", "mousemove"], function(e, event){
    return [e.pageX,e.pageY]
  })

  addPushers(["keydown", "keyup"], function(e, event){
    var unicode
    unicode = "0x" + e.keyIdentifier.split("+")[1];
    return unicode
  })

})()