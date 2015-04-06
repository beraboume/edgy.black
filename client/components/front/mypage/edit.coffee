module.exports.resolve=
  user: ($http,$state)->
    $http.get '/mypage/user'
    .then (result)->
      return $state.go 'front.mypage' if result.data is null
      result
  fields: ($http)->
    $http.get '/fields/User'
    .then (result)->
      result
    .catch (error)->
      console.log error
      error
  mypages: ($http)->
    $http.get '/mypages/'

module.exports.client= (
  $scope
  $http
  $state

  user
  fields
  mypages
)->
  $scope.user= user.data

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
    {name,bio,mypage_id}= $scope.user
    {files}= $scope
    file= files[0] or {}
    type= file.type
    size= file.size

    data= new FormData
    data.append key,value for key,value of {name,bio,mypage_id,file,type,size}
    $http.post '/mypage/edit/',data,
      headers:'Content-type':undefined
    .then (xhrResult)->
      localStorage.removeItem 'jaggy:'+xhrResult.data
      $state.transitionTo 'front.mypage',null,reload:yes
    .catch (error)->
      console.log error
      alert error.data

module.exports.server= (app)->
  fs= require 'fs'

  unlinkStorages= (user)->
    existsFile= user.Storage
    if existsFile
      path= require 'path'
      fs= require 'fs'
      wanderer= require 'wanderer'

      fileName= user.Storage.dataValues.key
      filePath= path.join process.env.STORAGE,fileName+'*'

      fs.unlinkSync file for file in wanderer.seekSync filePath

  app.post '/mypage/edit/',(req,res)->
    {name,bio,mypage_id,type,size}= req.body
    user_id= req.session.passport.user.id
    file= req.files.file

    old_url= null

    {Storage,User}= (require process.env.DB_ROOT).models
    User.find
      where:
        id: user_id
      include:
        [Storage]
    .then (user)->
      throw new Error 'Please login' if not user?
      throw new Error 'Over 1mb' if size>= Math.pow(2,20)

      return user if not file

      old_url= user.Storage.url
      unlinkStorages user

      path= require 'path'
      storage= user.Storage or Storage.build()
      fileName= storage.key+'.'+(require('mime').extension type)
      filePath= path.join process.env.STORAGE,fileName

      fs.renameSync file.path,filePath
      
      storage.type= type
      storage.url= process.env.STORAGE_URL+fileName
      storage.user_id= user_id
      storage.save()
      .then ->
        user.storage_key= storage.key
        user
    .then (user)->
      user.name= name
      user.bio= bio
      user.mypage_id= mypage_id
      user.save()
    .then ->
      res.json old_url

    .catch (error)->
      console.error error.stack
      res.status 403
      res.json error.message

  app.get '/mypages/',(req,res)->
    mypage_id= req.session.passport.user.mypage_id

    {User}= (require process.env.DB_ROOT).models
    User.findAll
      attributes: ['mypage_id']
      where:
        mypage_id:
          $ne:
            mypage_id
    .then (mypages)->
      res.json mypages
    .catch (error)->
      res.status 404
      res.json null