module.exports.client= ($scope,$stateParams,days)->
  $scope.days= days.data
  $scope.icon= "icons/#{$stateParams.type}.gif"
  $scope.title= 'MYPAGE_STATS_'+$stateParams.type.toUpperCase()

module.exports.resolve=
  days: ($http,$stateParams)->
    $http.get '/front/mypage/stats/'+$stateParams.type

module.exports.server= (app)->
  Promise= require 'sequelize/node_modules/bluebird'
  day= 60*60*24* 1000
  days= [0...16]

  app.get '/front/mypage/stats/:type',(req,res)->
    {type}= req.params

    queues= []
    switch type
      when 'add'
        queues= totalAdd req,res
 
      when 'comment'
        queues= totalComment req,res

      when 'view'
        queues= totalView req,res

    Promise.all queues
    .then (stats)->
      res.json stats
    .catch (error)->
      res.status 404
      res.json error.message

  totalAdd= (req,res)->
    queues= []

    user_id= req.session?.passport?.user?.id
    for i in days
      do (i)->
        db= require process.env.DB_ROOT
        {Artwork}= db.models

        promise= Artwork.count
          where:
            db.and [
              ['Artwork.user_id = ?',user_id]
              ['date(Artwork.created_at) = date(from_unixtime(?))',(Date.now()-i*day)/1000]
            ]...

        promise= promise.then (count)->
          title= i
          title= Date.now()-i*day if i>0

          {title,count}

        queues.push promise

    queues

  totalComment= (req,res)->
    queues= []

    user_id= req.session?.passport?.user?.id
    for i in days
      do (i)->
        db= require process.env.DB_ROOT
        {Comment,Artwork}= db.models

        promise= Comment.count
          where:
            db.and [
              {user_id: $ne: user_id}
              ['Artwork.user_id = ?',user_id]
              ['date(Artwork.created_at) = date(from_unixtime(?))',(Date.now()-i*day)/1000]
            ]...
          include: [Artwork]

        promise= promise.then (count)->
          title= i
          title= Date.now()-i*day if i>0

          {title,count}

        queues.push promise

    queues

  totalView= (req,res)->
    queues= []

    user_id= req.session?.passport?.user?.id
    for i in days
      do (i)->
        db= require process.env.DB_ROOT
        {View}= db.models

        promise= View.sum 'count',
          where:
            db.and [
              {user_id}
              ['date(View.date) = date(from_unixtime(?))',(Date.now()-i*day)/1000]
            ]...

        promise= promise.then (count)->
          title= i
          title= Date.now()-i*day if i>0
          count= 0 if isNaN count

          {title,count}

        queues.push promise

    queues