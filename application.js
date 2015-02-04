var stream = new WebSocket('ws://localhost:9393')
var videoElement = document.querySelector("#desktop")
var videoSource = document.querySelector("source")
window.MediaSource = window.MediaSource || window.WebKitMediaSource;
var mediaSource = new MediaSource()
videoElement.src = window.URL.createObjectURL(mediaSource)
// var videoElement.src = window.URL.createObjectURL(mediaSource)

stream.onopen = function(){
  console.log('connection open')
}

stream.onclose = function(){
  console.log('connection closed')
}

var queue = []


mediaSource.addEventListener('sourceopen', function(e){
  var sourceBuffer = mediaSource.addSourceBuffer('video/webm; codecs="vp8,vorbis"')

  stream.onmessage = function(e){
    var byteCharacters = atob(e.data)

    var byteNumbers = new Array(byteCharacters.length)
    for (var i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i)
    }

    var byteArray = new Uint8Array(byteNumbers)

    // var blob = new Blob([byteArray], {type: "video/ogg"})

    // var blobUrl = URL.createObjectURL(blob)

    // console.log('received blob')
    sourceBuffer.appendStream(new Uint8Array([1,2,3,4,5]))
    // queue.push(byteArray)
  }


}, false)


