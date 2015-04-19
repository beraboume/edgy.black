module.exports.client= (
  $scope
  user
  artwork
  fields

  $http
  $state
  $filter
)->
  return $state.go('error',null,location:'replace') if user.data?.id isnt artwork.data.User?.id

  $scope.fields= fields.data
  $scope.artwork= artwork.data

  $scope.show_types=
    for value in $scope.fields.show.values
      type= 
        value: value
        label: $filter('translate') 'ADD_SHOW_'+value

      $scope.show= type if $scope.artwork.show is type.value

      type

  $scope.fields= fields.data
  $scope.files= []
  $scope.$watch 'files',->
    file= $scope.files?[0]
    return if not file instanceof File

    url= URL.createObjectURL file if file instanceof File
    return if not url?
    jaggy.createSVG url,(error,svg)->
      throw error if error?
      a= document.querySelector('[ng-model="files"] a')
      a= angular.element a
      a.empty()
      a.append svg
  $scope.submit= ->
    {title,description}= $scope.artwork
    {files}= $scope
    file= files[0]
    type= file?.type
    size= file?.size
    show= $scope.show.value

    data= new FormData
    for key,value of {title,description,file,type,size,show}
      data.append key,value
    $http.put '/front/artwork/'+$state.params.id,data,
      headers:'Content-type':undefined
    .then (xhrResult)->
      # via module.exports.server ...
      {artwork}= xhrResult.data

      $state.go 'front.view',id:artwork.id,reload:yes
    .catch (error)->
      alert error.data

module.exports.resolve=
  artwork: ($http,$stateParams)->
    $http.get '/front/artwork/'+$stateParams.id

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  fs= require 'fs'
  path= require 'path'
  crypto= require 'crypto'

  mime= require 'mime'
  Promise= require 'sequelize/node_modules/bluebird'

  unlink= (Storage)->
    path= require 'path'
    fs= require 'fs'
    wanderer= require 'wanderer'

    filePath= path.join process.env.STORAGE,Storage.key+'*'
    fs.unlinkSync file for file in wanderer.seekSync filePath

  app.put '/front/artwork/:id',(req,res)->
    {id}= req.params
    {title,description,type,size,show}= req.body
    {file}= req.files
    user_id= req.session.passport.user?.id

    {Artwork,Storage}= db.models
    Artwork.find
      where: {id,user_id}
      include: [Storage]
    .then (artwork)->
      artwork.title= title
      artwork.description= description
      artwork.show= show

      artwork.save()
    .then (artwork)->
      return artwork if not file?

      console.log file

      sha1= crypto.createHash('sha1').update(file.buffer.toString()).digest('hex')
      Storage.find where: {sha1}
      .then (duplicated)->
        throw new Error 'Exists file' if duplicated?
        throw new Error 'Over 1mb' if size>= Math.pow(2,20)

        storage= artwork.Storage
        storage.type= type

        fileName= storage.key+'.'+(mime.extension type)
        filePath= path.join process.env.STORAGE,fileName

        unlink artwork.Storage
        fs.writeFileSync filePath,file.buffer
        
        storage.sha1= sha1
        storage.url= process.env.STORAGE_URL+fileName
        storage.save()
        .then ->
          artwork
    .then (artwork)->
      res.json {artwork}

    .catch (error)->
      console.error error.stack
      res.status 403
      res.json error.message