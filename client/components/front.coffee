module.exports.client= ($scope,$state,user)->  
  $scope.user= user.data
  $scope.states= 
    'front.index':
      icon: 'icons/top.gif'
      title: 'トップ'

    'front.view':
      icon: 'icons/image.gif'
      title: 'さくひん'
      'ng-hide':'!$state.params.id'
    'front.edit':
      icon: 'icons/edit.gif'
      title: 'へんしゅう'
      'ng-hide':'!$state.params.id || isOtherPage'
    'front.remove':
      icon: 'icons/remove.gif'
      title: 'さくじょ'
      'ng-hide':'!$state.params.id || isOtherPage'
    'front.add':
      icon: 'icons/add.gif'
      title: 'とうこう'
      'ng-hide':'!user.id || !$state.includes("front")'

    'front.mypage':
      icon: 'icons/authorize.gif'
      title: 'アカウント'
    'front.mypage.edit':
      icon: 'icons/mypage.gif'
      title: 'プロフィール'
      'ng-hide':'!$state.is("front.mypage.edit")'
    'front.mypage.quit':
      icon: 'icons/quit.gif'
      title: '退会する'
      'ng-hide':'!$state.is("front.mypage.quit")'

module.exports.resolve=
  fields: ($http)->
    $http.get '/fields/Artwork'
  user: ($http)->
    $http.get '/mypage/user'

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get '/mypage/user',(req,res)->
    {mypage_id}= req.query
    requested= mypage_id?

    mypage_id= req.session?.passport?.user?.mypage_id if not mypage_id

    {User,Storage}= (require process.env.DB_ROOT).models
    User.find
      where: mypage_id: mypage_id
      include: [Storage]
    .then (user)->
      throw new Error 'Notfound' if requested and not user?
      res.json user
    .catch (error)->
      res.status 404
      res.json error
      
  app.get '/fields/:modelName',(req,res)->
    try
      model= db.models[req.params.modelName]
      fields= {}
      for key,value of model.rawAttributes
        field= value.type or {}
        field= {_length:4096} if Object.keys(field).length is 0
        fields[key]= field
    catch error
      console.error error

    res.status 404 if not fields?
    res.json fields