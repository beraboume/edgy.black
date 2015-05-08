module.exports.client= (
  $scope
  $http
  artworks
)->
  $scope.$root.og['title']= '卍'
  $scope.artworks= artworks.data

  $scope.find= (words)->
    url= '/front/artworks'
    url= "/front/artworks/#{words}" if words.length
    $http.get url
    .then (result)->
      $scope.artworks= result.data

module.exports.resolve=
  artworks: ($http)->
    $http.get '/front/artworks'

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get '/front/artworks',(req,res)->
    {_start,_end}= req.query
    
    {Artwork,Storage}= db.models
    Artwork.findAll
      where:
        show: 'PUBLIC'
      offset: _start
      limit: _end-_start
      order: 'created_at desc'
      include: [Storage]
    .then (artworks)->
      res.json artworks

    .catch (error)->
      res.status 404
      res.json error.stack

  app.get '/front/artworks/:words',(req,res)->
    {_start,_end}= req.query
    words= req.params.words.split /\s+/,3

    conditions= []
    for word in words
      conditions.push title: like:"%#{word}%"
      conditions.push description: like:"%#{word}%"

    {Artwork,Storage}= db.models
    Artwork.findAll
      where: db.or conditions...
      offset: _start
      limit: _end-_start
      order: 'created_at desc'
      include: [Storage]
    .then (artworks)->
      res.json artworks
    .catch (error)->
      console.error error

      res.status 404
      res.json error