module.exports.resolve=
  artworks: ($http,user)->
    $http.get '/mypage/artworks/'+user.data.id

module.exports.server= (app)->
  app.get '/mypage/artworks/:user_id',(req,res)->
    {user_id}= req.params

    {Artwork,Storage}= (require process.env.DB_ROOT).models
    Artwork.findAll
      where:
        user_id: user_id
        show:
          $ne: 'SECRET'
      include: [Storage]
    .then (artwork)->
      res.json artwork
    .catch (error)->
      console.error error.stack
      res.status 404
      res.json error.stack

module.exports.client= (
  $scope
  user
  artworks
)-> 
  $scope.user= user.data
  if $scope.user.Storage
    $scope.user.Storage.url= $scope.user.Storage.url.replace /http:\/\/.+?\//,'http://'+window.location.host+'/'

  $scope.artworks= artworks.data.map (artwork)->
    artwork.Storage.url= artwork.Storage.url.replace /http:\/\/.+?\//,'http://'+window.location.host+'/'
    
    artwork
