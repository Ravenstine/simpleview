var stream = new WebSocket('ws://104.8.69.205:9393')
var videoElement = document.querySelector("video")

stream.onopen = function(){
  console.log('connection open')
}

stream.onclose = function(){
  console.log('connection closed')
}


stream.onmessage = function(e){

}

videoElement.addEventListener("mousemove", function(e){
  var xOffset, yOffset, x, y, data, message

  xOffset = videoElement.offsetLeft
  yOffset = videoElement.offsetTop

  x = e.clientX + xOffset
  y = e.clientY + yOffset
  data = {event: 'mousemove', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})

document.body.addEventListener("click", function(e){
  var xOffset, yOffset, x, y, data, message

  xOffset = videoElement.offsetLeft
  yOffset = videoElement.offsetTop

  x = e.clientX + xOffset
  y = e.clientY + yOffset
  data = {event: 'click', data: [x,y]}

  message = JSON.stringify(data)
  stream.send(message)
})