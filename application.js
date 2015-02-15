(function(){

  var stream = new WebSocket('ws://' + window.location.hostname + ':9494' + window.location.search)
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

  addPushers(["mouseup", "mousedown"], function(e, event){
    e.preventDefault()
    return {constant: "Mouse", method: event, arguments: [e.pageX, e.pageY, e.which]}
  })

  addPushers(["mousemove"], function(e, event){
    e.preventDefault()
    return {constant: "Mouse", method: event, arguments: [e.pageX, e.pageY]}
  })


  addPushers(["keydown", "keyup"], function(e, event){
    return {constant: "Keyboard", method: event, arguments: [e.which]}
  })

  addEventListener("contextMenu", function(){
    return false
  })


})()