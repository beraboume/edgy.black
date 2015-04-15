module.exports.client= (
  $scope
  $http

  $state

  user
)->
  $scope.mypage_id_confirm= new RegExp "^#{user.data.mypage_id}$"
  $scope.submit= ->
    $http.delete '/mypage/user/'+$scope.mypage_id
    .then ->
      alert 'Thankyou for your playing!'
      $state.go 'front.mypage',null,reload:yes
    .catch (message)->
      alert message

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
  wanderer= require 'wanderer'

  app.delete '/mypage/user/:mypage_id',(req,res)->
    {mypage_id}= req.params
    id= user_id= req.session.passport.user.id

    user= null

    # TODO USERの論理削除
    {User,Artwork,Storage}= db.models
    User.find where:{id,mypage_id}
    .then (userData)->
      throw new Error 'Invalid mypage_id' if userData is null
      user= userData
    .then ->
      Artwork.destroy where:{user_id}
    .then ->
      Storage.findAll where:{user_id}
    .then (storages)->
      globs= []
      globs.push path.join process.env.STORAGE,"#{storage.key}.*" for storage in storages
      files= wanderer.seekSync globs
      fs.unlinkSync file for file in files
    .then ->
      Storage.destroy where:{user_id}
    .then ->
      user.destroy()
    .then ->
      req.session.destroy (error)->
        throw error if error?

        res.json null
    .catch (error)->
      console.log error

      res.status 400
      res.json error.message
