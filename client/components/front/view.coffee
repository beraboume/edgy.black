module.exports.client= (
  $rootScope
  $scope
  $state
  user
  artwork
  detail
  comment_count

  $window

  $http
  fields
)->
  $scope.artwork= artwork.data
  $scope.detail= detail.data
  $scope.comment_count= comment_count.data
  $scope.fields= fields.data

  $rootScope.meta['og:title']= artwork.data.title+' by '+artwork.data.User.name

  $scope.image= null
  $scope.colors= {}
  $scope.palette= (scope,element,attrs)->
    image= element[0]
    width= image.getAttribute 'width'
    height= image.getAttribute 'height'

    paths= image.querySelectorAll 'path'
    for path in paths
      color= {}
      background= path.getAttribute 'fill'

      values= []
      rgb= sliceRGBA background
      for value,i in rgb
        break if i>2
        values.push ('00'+value).slice -3
      color.rgb= values.join(',')
      color.rgba= background
      color.opacity= rgb[3]

      color.style=
        background: background

      $scope.colors[color.rgba]= color

    $scope.detail.image= width+'x'+height
    $scope.image= image
  sliceRGBA= (fill)->
    rgba= fill
    rgba= rgba.slice 5
    rgba= rgba.slice 0,rgba.length-1
    rgba= rgba.split ','
    rgba
  darken= (fill)->
    rgba= sliceRGBA fill
    rgba[0]= parseInt(rgba[0]* .5)
    rgba[1]= parseInt(rgba[1]* .5)
    rgba[2]= parseInt(rgba[2]* .5)

    "rgba(#{rgba.join(',')})"
  $scope.focus= (color)->
    paths= $scope.image.querySelectorAll 'path'
    for path in paths
      fill= path.getAttribute 'original-fill'
      fill?= path.getAttribute 'fill'
      if color.rgba is fill
        if color.checked
          path.setAttribute 'fill','white'
          path.setAttribute 'original-fill',fill
        else
          path.setAttribute 'fill',fill
          path.removeAttribute 'original-fill',fill

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
  detail: ($http,$stateParams)->
    $http.get '/front/artwork/'+$stateParams.id+'/detail'
  fields: ($http)->
    $http.get '/fields/Comment'

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  debug= (require 'debug') 'edgy:server'

  app.get '/front/artwork/:id',(req,res)->
    req.session.views= [] if not req.session.views?
    
    artwork= null

    {id}= req.params
    user_id= req.session.passport.user?.id

    {Artwork,Comment,Storage,User,View}= db.models
    Artwork.find
      where: Artwork.getWhereFromVisible id,user_id
      include: [Storage,{
        model: User
        include: [Storage]
      }]
    .then (result)->
      throw new Error 'Notfound' if not result?
      artwork= result

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
    .then (detail)->
      res.json artwork

    .catch (error)->
      res.status 404
      res.json error.message

  app.get '/front/artwork/:artwork_id/detail',(req,res)->
    {artwork_id}= req.params
    user_id= req.session.passport.user?.id

    {Comment,View}= db.models

    detail=
      image: 0
      palette: 0
      view: 0
      comment: 0

    View.sum 'count',
      where:
        {artwork_id}
    .then (view)->
      detail.view= view

      Comment.count
        where:
          {artwork_id}
    .then (comment)->
      detail.comment= comment

      res.json detail

  app.get '/front/comments/:artwork_id',(req,res)->
    {artwork_id}= req.params
    {_start,_end}= req.query

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
