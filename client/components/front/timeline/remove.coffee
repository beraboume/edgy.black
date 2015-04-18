REST= '/front/timeline/'

module.exports.client= (
  $scope
  $stateParams

  comment

  $http
  $state
)->
  $scope.comment= comment.data
  $scope.remove= ->
    $http.delete REST+$stateParams.comment_id
    .then ->
      $state.go '^',null,reload:yes
    .catch (error)->
      console.log error
      alert error.data.message

module.exports.resolve=
  comment:($http,$stateParams)->
    $http.get REST+$stateParams.comment_id

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get REST+':id',(req,res)->
    {id}= req.params
    user_id= req.session.passport.user.id

    {Comment,Artwork,User,Storage}= db.models
    Comment.find
      where: {id,user_id}
      include: [Artwork,{
        model: User
        include: [Storage]
      }]
    .then (comment)->
      return res.status(404).json null if not comment?
      res.json comment
    .catch (error)->
      res.status 500
      res.json error

  # この文法よく出る（RESTクラス作れそう）
  app.delete REST+':id',(req,res)->
    {id}= req.params
    user_id= req.session.passport.user.id

    {Comment}= db.models
    Comment.find
      where: {id,user_id}
    .then (comment)->
      comment.destroy()
    .then ->
      res.json null
    .catch (error)->
      res.status 500
      res.json error
