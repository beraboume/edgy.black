module.exports.client= (
  $scope
  stats

  $http
  $state

  $window
)->
  $scope.stats= stats.data
  $scope.logout= ->
    $http.delete '/mypage/auth'
    .then ->
      $state.reload()
  $scope.scrollHead= ->
    $window.scrollTo 0,0

module.exports.resolve=
  stats: ($http)->
    $http.get '/front/stats'

module.exports.server= (app)->
  app.get '/front/stats',(req,res)->
    user_id= req.session?.passport?.user?.id

    artworks= views= favorites= comments= 0

    db= require process.env.DB_ROOT
    {Artwork,View,Favorite,Comment}= db.models
    Artwork.count
      where:
        {user_id}
    .then (count)->
      artworks= count

      Artwork.count
        include: [Favorite]
        where: 
          $and: [
            user_id: user_id
            ['Favorites.user_id <> ?',user_id]
          ]

    .then (count)->
      favorites= count

      View.sum 'count',
        where:
          {user_id}
    .then (result)->
      views= result
      views= 0 if isNaN views

      Comment.count
        where:
          [
            ['Artwork.user_id = ?',user_id]
            user_id:
              $ne: user_id
          ]
        include: [Artwork]
    .then (comments)->
      res.json {artworks,views,favorites,comments}

    .catch (error)->
      console.error error.stack

  passport= require process.env.SERVER_ROOT+'/passport'

  app.delete '/mypage/auth',(req,res)->
    req.session.destroy (error)->
      throw error if error?

      res.json null

  app.get '/mypage/auth',(req,res,next)->
    req.session.back= req.header 'Referer'
    req.session.save (error)->
      throw error if error?
      next()
  app.get '/mypage/auth',passport.authenticate 'twitter'
  app.get '/mypage/auth/callback',passport.authenticate 'twitter',{
  # app.get '/mypage/auth/callback',passport.authenticate 'twitter',{
    successRedirect: '/mypage/auth/success/'
    failureRedirect: '/mypage/auth/failure/'
  }
  app.get '/mypage/auth/success/',(req,res)->
    url= '/mypage'
    url= req.session.back if req.session.back?
    delete req.session.back if req.session.back?

    res.redirect url
  app.get '/mypage/auth/failure/',(req,res)->
    delete req.session.back if req.session.back?
    res.end 'だめでした'