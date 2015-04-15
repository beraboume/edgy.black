# Dependencies
path= require 'path'

module.exports= (req)->
  fileName= req.url.slice(1) or 'index'
  fileName= path.join fileName,'index' if fileName.slice(-1) is '/'
  fileName+= '.jade' if fileName.indexOf('.jade') is -1

  filePath= fileName
  filePath= path.join process.env.ROOT,process.env.PUBLIC,filePath
  filePath
