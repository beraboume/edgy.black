module.exports.client= ($scope,$state,user)->  
  $scope.user= user.data
  $scope.states= 
    'front.index':
      icon: 'icons/top.gif'
      title: 'TOP'

    'front.view':
      icon: 'icons/image.gif'
      title: 'VIEW'
      'ng-hide':'!$state.params.id'
    'front.edit':
      icon: 'icons/edit.gif'
      title: 'EDIT'
      'ng-hide':'!$state.params.id || isOtherPage'
    'front.remove':
      icon: 'icons/remove.gif'
      title: 'DELETE'
      'ng-hide':'!$state.params.id || isOtherPage'
    'front.add':
      icon: 'icons/add.gif'
      title: 'ADD'
      'ng-hide':'!user.id || !$state.includes("front")'

    'front.mypage':
      icon: 'icons/authorize.gif'
      title: 'MYPAGE'
    'front.mypage.edit':
      icon: 'icons/mypage.gif'
      title: 'MYPAGE_EDIT'
      'ng-hide':'!$state.is("front.mypage.edit")'
    'front.mypage.quit':
      icon: 'icons/quit.gif'
      title: 'MYPAGE_QUIT'
      'ng-hide':'!$state.is("front.mypage.quit")'

    "i18n":
      icon: 'icons/i18n.gif'
      title: 'I18N'
      'ng-hide':'!$state.is("front.index")'
    "glitch":
      icon: 'icons/glitch.gif'
      title: 'GLITCH'
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