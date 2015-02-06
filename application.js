var stream = new WebSocket('ws://10.10.0.187:9393')
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

  x = e.clientX
  y = e.clientY
  data = {event: 'mousemove', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})

document.body.addEventListener("click", function(e){
  var xOffset, yOffset, x, y, data, message

  x = e.clientX
  y = e.clientY
  data = {event: 'click', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})