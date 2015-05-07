REST= '/front/mypage/favorites'

module.exports.client= ($scope,artworks)->
  $scope._artworks= artworks.data
  $scope.$watch 'artworks',(newValue)->
    delete $scope._artworks if newValue?

module.exports.resolve=
  user: ($http,$state)->
    $http.get '/mypage/user'
    .then (result)->
      return $state.go 'front.mypage' if result.data is null
      result
  artworks: ($http)->
    $http.get REST

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get REST,(req,res)->
    user_id= req.session.passport.user?.id
    {_start,_end}= req.query
    _start?= 0
    _end?= 0

    {Artwork,Storage,Favorite}= db.models
    Artwork.findAll
      where:
        $and: [
          $or: [
            {show: 'PUBLIC'}
            {show: 'PRIVATE'}
            {
              show: 'SECRET'
              user_id: user_id
            }
          ]
          ['Favorites.user_id = ?',user_id]
        ]
      offset: _start
      limit: _end-_start
      order: 'created_at desc'
      include: [Storage,Favorite]
    .then (artworks)->
      res.json artworks
    .catch (error)->
      res.status 500
      res.end error.toString()
