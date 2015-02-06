var stream = new WebSocket('ws://104.8.69.205:9393')
var imageElement = document.querySelector("img")

stream.onopen = function(){
  console.log('connection open')
}

stream.onclose = function(){
  console.log('connection closed')
}


stream.onmessage = function(e){
  var img = document.querySelector('img')
  img.src = "data:image/jpg;base64," + e.data
}

imageElement.addEventListener("mousemove", function(e){
  var xOffset, yOffset, x, y, data, message

  xOffset = imageElement.offsetLeft
  yOffset = imageElement.offsetTop

  x = e.clientX + xOffset
  y = e.clientY + yOffset
  data = {event: 'mousemove', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})

imageElement.addEventListener("click", function(e){
  var xOffset, yOffset, x, y, data, message

  xOffset = imageElement.offsetLeft
  yOffset = imageElement.offsetTop

  x = e.clientX + xOffset
  y = e.clientY + yOffset
  data = {event: 'click', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})