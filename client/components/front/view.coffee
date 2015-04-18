module.exports.client= (
  $rootScope
  $scope
  $state
  user
  artwork
  comment_count

  $window

  $http
  fields
)->
  $scope.artwork= artwork.data
  $scope.comment_count= comment_count.data
  $scope.fields= fields.data

  $scope.share= (url,params={},name='share',featureString='width=465,height=465')->
    params.url= $window.location.href
    params.via= 'edgy_black'
    params.hashtags= 'pixelart'

    queries= []
    queries.push encodeURIComponent(key)+"="+encodeURIComponent(value) for key,value of params

    $window.open url+'?'+queries.join('&'),name,featureString
    return

  $scope.comment= (body)->
    data= new FormData
    data.append 'body',body
    $http.post "/front/comments/#{artwork.data.id}",data,headers:'Content-type':undefined
    .then (result)->
      $state.reload()

  $rootScope.user= user.data
  $rootScope.isOtherPage= user.data?.id isnt artwork.data.User?.id

module.exports.resolve=
  comment_count: ($http,$stateParams)->
    $http.get '/front/comments/'+$stateParams.id+'/?count=1&_start=0&end_0'
  artwork: ($http,$stateParams)->
    $http.get '/front/artwork/'+$stateParams.id
  fields: ($http)->
    $http.get '/fields/Comment'

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  debug= (require 'debug') 'edgy:server'

  app.get '/front/comments/:artwork_id',(req,res)->
    {artwork_id}= req.params
    {_start,_end}= req.query
    
    debug 'TODO 匿名コメントの許可'
    debug 'TODO 連投の許容時間'

    {Comment,User,Storage}= db.models
    Comment.findAndCountAll
      where: {artwork_id}
      order: 'created_at desc'
      offset: _start
      limit: _end-_start
      include: [{
        model: User
        include: [Storage]
      }]
    .then (result)->
      return res.json result.count if req.query.count?
      res.json result.rows
    .catch (error)->
      res.status 404
      res.json null

  app.post '/front/comments/:artwork_id',(req,res)->
    {body}= req.body
    {artwork_id}= req.params
    user_id= req.session.passport.user.id

    {Comment}= db.models
    comment= Comment.build {artwork_id,user_id,body}
    comment.save()
    .then (result)->
      res.json result
    .catch ->
      res.status 400
      res.json null

  app.get '/front/artwork/:id',(req,res)->
    req.session.views= [] if not req.session.views?
    
    artwork= null

    {id}= req.params

    {Artwork,Storage,User,View}= db.models
    Artwork.find
      where: {id}
      include: [Storage,{
        model: User
        include: [Storage]
      }]
    .then (result)->
      throw new Error 'Notfound' if not result?
      artwork= result

      # TODO testを書け
      View.findOrCreate
        where:[
          ['date(`date`) = date(?)',new Date]
          artwork_id: id
        ]
        defaults:
          date: new Date
          count: 0
          user_id: artwork.user_id
          artwork_id: artwork.id
    .then (results)->
      [view,created]= results
      isOther= artwork.user_id isnt req.session.passport?.user?.id
      isVisit= not (view.id in req.session.views)
      if isOther and isVisit
        view.count++ 
        req.session.views.push view.id

      view.save()
    .then ->
      res.json artwork

    .catch (error)->
      res.status 404
      res.json error.message
