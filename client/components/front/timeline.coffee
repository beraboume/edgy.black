module.exports.client= (
  $scope
  fields
  
  $http
  $state
)->
  $scope.fields= fields.data

  $scope.comment= (body)->
    data= new FormData
    data.append 'body',body
    $http.post "/front/timeline/",data,headers:'Content-type':undefined
    .then (result)->
      $state.reload()

module.exports.resolve=
  fields: ($http)->
    $http.get '/fields/Comment'

module.exports.server= (app)->
  db= require process.env.DB_ROOT
  Sequelize= db.constructor

  app.get '/front/timeline/',(req,res)->
    {_start,_end}= req.query
    
    {Comment,User,Storage,Artwork}= db.models
    Comment.findAll
      where:
        Sequelize.or [
          'Artwork.id is null'
          ['Artwork.show in (?)', ['PUBLIC','PRIVATE']]
        ]...
      order: 'created_at desc'
      offset: _start
      limit: _end-_start
      include: [{
        model: User
        include: [Storage]
      },Artwork]
    .then (comments)->
      res.json comments
    .catch (error)->
      res.status 404
      res.json null

  app.post '/front/timeline/',(req,res)->
    {body}= req.body
    user_id= req.session.passport.user.id

    {Comment}= db.models
    comment= Comment.build {user_id,body}
    comment.save()
    .then (result)->
      res.json result
    .catch ->
      res.status 400
      res.json null