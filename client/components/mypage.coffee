module.exports.client= (
  $scope

  user
)->
  $scope.$root.og['title']= user.data.name
  $scope.$root.og['description']= user.data.bio.replace /"/,'&quot;'

  $scope.user= user.data
  $scope.states= 
    'mypage.index':
      icon: 'icons/mypage.gif'
      title: 'WEBSITE'
    "i18n":
      icon: 'icons/i18n.gif'
      title: 'I18N'
    "#{process.env.PUBLIC_URL}":
      icon: 'icons/top.gif'
      title: 'TOP'

module.exports.resolve=
  user: (mypageId,$http,$state)->
    $http.get '/mypage/user/?mypage_id='+mypageId

  artworks: (user,$http)->
    $http.get '/front/artworks/'+user.data.id