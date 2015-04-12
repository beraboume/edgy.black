module.exports.client= (
  $scope

  user
)->
  $scope.user= user.data
  $scope.states= 
    'mypage.index':
      icon: 'icons/desk.gif'
      title: 'WEBSITE'
    "#{process.env.PUBLIC_URL}":
      icon: 'icons/top.gif'
      title: 'TOP'

module.exports.resolve=
  user: (mypageId,$http,$state)->
    $http.get '/mypage/user/?mypage_id='+mypageId

  artworks: (user,$http)->
    $http.get '/front/artworks/'+user.data.id