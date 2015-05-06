REST= '/favorite/'

module.exports.client= (app)->
  app.config ($stateProvider)->
    $stateProvider.state 'front.view.favorite',
      url: '/favorite/'
      templateProvider: ($http,$state,$stateParams)->
        $http.get REST+$stateParams.id
        .then ->
          $state.reload()
        .catch (error)->
          alert error.data
          $state.reload()

  app.config ($stateProvider)->
    $stateProvider.state 'front.view.unfavorite',
      url: '/unfavorite/'
      templateProvider: ($http,$state,$stateParams)->
        $http.delete REST+$stateParams.id
        .then ->
          $state.reload()
        .catch (error)->
          alert error.data
          $state.reload()

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get REST+':artwork_id',(req,res)->
    user_id= req.session.passport.user.id
    {artwork_id}= req.params

    {Favorite}= db.models
    Favorite.findOrCreate
      where: {user_id,artwork_id}
    .then (favorite)->
      res.json favorite

    .catch (error)->
      res.status 500
      res.json error.toString()

  app.delete REST+':artwork_id',(req,res)->
    user_id= req.session.passport.user.id
    {artwork_id}= req.params

    {Favorite}= db.models
    Favorite.find
      where: {user_id,artwork_id}
    .then (favorite)->
      favorite.destroy()
    .then (favorite)->
      res.json favorite

    .catch (error)->
      res.status 500
      res.json error.toString()