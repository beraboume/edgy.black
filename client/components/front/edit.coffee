module.exports.client= (
  $scope
  user
  artwork
  fields

  $http
  $state
)->
  return $state.go('error',null,location:'replace') if user.data?.id isnt artwork.data.User?.id

  $scope.fields= fields.data
  $scope.artwork= artwork.data
  $scope.submit= ->
    {title,description}= $scope.artwork

    data= new FormData
    for key,value of {title,description}
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

  app.put '/front/artwork/:id',(req,res)->
    {id}= req.params
    {title,description}= req.body
    user_id= req.session.passport.user?.id

    {Artwork}= db.models
    Artwork.find where: {id,user_id}
    .then (artwork)->
      artwork.title= title
      artwork.description= description

      artwork.save()
    .then (artwork)->
      res.json {artwork}

    .catch (error)->
      console.error error.stack
      res.status 403
      res.json error.message