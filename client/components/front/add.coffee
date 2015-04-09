module.exports.client= ($scope,$http,$state,fields)->
  $scope.fields= fields.data
  $scope.files= []
  $scope.$watch 'files',->
    file= $scope.files?[0]
    return if not file instanceof File

    url= URL.createObjectURL file if file instanceof File
    return if not url?
    jaggy url,(error,svg)->
      throw error if error?
      a= document.querySelector('[ng-model="files"] a')
      a.innerHTML= svg.outerHTML
  $scope.submit= ->
    {title,description}= $scope.artwork
    {files}= $scope
    file= files[0]
    type= file.type
    size= file.size

    data= new FormData
    for key,value of {title,description,file,type,size}
      data.append key,value
    $http.post '/front/artworks/add/',data,headers:'Content-type':undefined
    .then (xhrResult)->
      {artwork}= xhrResult.data

      $state.go 'front.view',id:artwork.id
    .catch (error)->
      alert error.data

module.exports.resolve=
  user: ($http,$state)->
    $http.get '/mypage/user'
    .then (result)->
      return $state.go 'front.mypage' if result.data is null
      result

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  fs= require 'fs'
  path= require 'path'
  crypto= require 'crypto'

  mime= require 'mime'

  lwip= require 'lwip'
  Promise= require 'sequelize/node_modules/bluebird'
  OAuth= (require 'oauth').OAuth
  oauth= new OAuth 'https://api.twitter.com/oauth/request_token',
    'https://api.twitter.com/oauth/access_token',
    process.env.consumerKey,
    process.env.consumerSecret,
    '1.0A',
    null,
    'HMAC-SHA1'

  app.post '/front/artworks/add/',(req,res)->
    {title,description,data,type,size}= req.body
    user_id= req.session.passport.user.id
    user_name= req.session.passport.user.name
    # file= new Buffer (data.slice 1+data.indexOf ','),'base64'# atob
    file= req.files.file
    fileData= fs.readFileSync(file.path).toString()
    sha1= crypto.createHash('sha1').update(fileData).digest('hex')

    filePath= null

    {Storage,Artwork}= db.models
    Storage.find where: {sha1}
    .then (duplicated)->
      throw new Error 'Exists file' if duplicated?
      throw new Error 'Over 1mb' if size>= Math.pow(2,20)

      storage= Storage.build()
      storage.type= type

      fileName= storage.key+'.'+(mime.extension type)
      filePath= path.join process.env.STORAGE,fileName

      fs.renameSync file.path,filePath
      
      storage.sha1= sha1
      storage.url= process.env.STORAGE_URL+fileName
      storage.user_id= user_id
      storage.save()
    .then (storage)->
      artwork= Artwork.build()
      artwork.user_id= user_id
      artwork.storage_key= storage.key
      artwork.title= title
      artwork.description= description

      artwork.save()
    .then (artwork)->
      res.json {artwork}

      # Notify for @edgy_black
      messageLimit= 140 - 40
      message= " by #{user_name} #{process.env.PUBLIC_URL}#{artwork.id} #pixelart"
      messageArtwork= "#{artwork.title} #{artwork.description}"
      if messageArtwork.length+ message.length< messageLimit
        message= messageArtwork + message
      else
        message= messageArtwork.slice(0,messageLimit-message.length-3)+'...' + message

      lwip.openAsync filePath
      .then (image)->
        Promise.promisifyAll image
        image.scaleAsync 10,'nearest-neighbor'
      .then (image)->
        Promise.promisifyAll image
        image.toBufferAsync 'png'
      .then (buffer)->
        new Promise (resolve,reject)->
          body=
            media: buffer.toString 'base64'
          oauth.post 'https://upload.twitter.com/1.1/media/upload.json',
            process.env.accessToken,
            process.env.accessSecret,
            body,(error,json)->
              resolve json if not error?
              reject error if error?
      .then (json)->
        new Promise (resolve,reject)->
          {media_id_string}= JSON.parse json
          body=
            media_ids:
              [media_id_string]
            status:
              message

          oauth.post 'https://api.twitter.com/1.1/statuses/update.json',
            process.env.accessToken,
            process.env.accessSecret,
            body,(error,json)->
              resolve json if not error?
              reject error if error?
      .catch (error)->
        console.error 'failure update status(',message.length,'):'
        console.error message,error

    .catch (error)->
      console.error error.stack
      res.status 403
      res.json error.message