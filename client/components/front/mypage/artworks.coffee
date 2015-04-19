REST= '/front/mypage/artworks'

module.exports.client= ($scope,artworks)->
  $scope._artworks= artworks.data
  $scope.$watch 'artworks',(newValue)->
    delete $scope._artworks if newValue?

module.exports.resolve=
  artworks: ($http)->
    $http.get REST

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get REST,(req,res)->
    user_id= req.session.passport.user.id
    {_start,_end}= req.query
    _start?= 0
    _end?= 0

    {Artwork,Storage}= db.models
    Artwork.findAll
      where: {user_id}
      offset: _start
      limit: _end-_start
      order: 'created_at desc'
      include: [Storage]
    .then (artworks)->
      res.json artworks
    .catch (error)->
      res.status 500
      res.error error
