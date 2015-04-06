module.exports.client= (
  $rootScope
  $scope
  $state
  user
  artwork

  $http
)->
  return $state.go('error',null,location:'replace') if user.data?.id isnt artwork.data.User?.id

  $scope.artwork= artwork.data

  $rootScope.user= user.data
  $rootScope.isOtherPage= user.data?.id isnt artwork.data.User?.id

  $scope.remove= ->
    $http.delete '/front/artwork/'+artwork.data.id
    .then (xhrResult)->
      $state.go 'front.index',null,reload:yes
    .catch (error)->
      alert error?.data

module.exports.resolve=
  artwork: ($http,$stateParams)->
    $http.get '/front/artwork/'+$stateParams.id

module.exports.server= (app)->
  app.delete '/front/artwork/:id',(req,res)->
    {id}= req.params
    user_id= req.session.passport.user.id

    {Artwork,Storage}= (require process.env.DB_ROOT).models
    Artwork= require process.env.DB_ROOT+'/Artwork'
    Artwork.find
      where: {id,user_id}
      include:[Storage]
    .then (artwork)->
      return res.json null if artwork is null

      artwork.destroy()
      .then ->
        artwork.Storage.destroy()
      .then ->
        path= require 'path'
        fs= require 'fs'
        wanderer= require 'wanderer'

        fileName= artwork.Storage.dataValues.key
        filePath= path.join process.env.STORAGE,fileName+'*'

        fs.unlinkSync file for file in wanderer.seekSync filePath

        res.json artwork
    .catch (error)->
      console.error error.stack
      res.status 403
      res.json error.message