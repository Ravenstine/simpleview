var stream = new WebSocket('ws://' + window.location.hostname + ':9393?server=firstpost')
var imageElement = document.querySelector("img")

stream.onopen = function(){
  console.log('connection open')
}

stream.onclose = function(){
  console.log('connection closed')
}

stream.onmessage = function(e){
  imageElement.src = "data:image/jpg;base64," + e.data
}

document.body.addEventListener("mousemove", function(e){
  var xOffset, yOffset, x, y, data, message

  x = e.pageX
  y = e.pageY
  data = {event: 'mousemove', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})

document.body.addEventListener("click", function(e){
  var xOffset, yOffset, x, y, data, message

  x = e.pageX
  y = e.pageY
  data = {event: 'click', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})