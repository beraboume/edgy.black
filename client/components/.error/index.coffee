module.exports.client= ->
  pixelSize= 5
  interval= 50

  targetContext= document.querySelector('#world').getContext('2d')
  context= document.createElement('canvas').getContext('2d')
  
  setTimeout ->
    noise()

  noise= ->
    if targetContext.canvas.width isnt innerWidth or targetContext.canvas.height isnt innerHeight
      targetContext.canvas.width= innerWidth
      targetContext.canvas.height= innerHeight
      targetContext.imageSmoothingEnabled= off
      targetContext.msImageSmoothingEnabled= off
      targetContext.mozImageSmoothingEnabled= off
      targetContext.webkitImageSmoothingEnabled= off
      context.canvas.width= innerWidth/pixelSize
      context.canvas.height= innerHeight/pixelSize

    image= context.createImageData context.canvas.width,context.canvas.height
    i= 0
    for x in [0...context.canvas.width]
      for y in [0...context.canvas.height]
        value= parseInt(255*Math.random()*.5)
        image.data[i]= value
        image.data[i+1]= value
        image.data[i+2]= value
        image.data[i+3]= 255
        i+= 4

    context.putImageData(image,0,0)
    targetContext.drawImage(context.canvas,0,0,innerWidth,innerHeight)

    setTimeout noise,interval

module.exports.server= (app)->
  fs= require 'fs'
  lookup= require "#{process.env.UTILS_ROOT}/lookup"

  app.use (req,res)->
    filePath= lookup req
    res.status 404 unless fs.existsSync filePath
    res.render 'index'