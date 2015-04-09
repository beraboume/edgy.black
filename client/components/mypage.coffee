module.exports.client= (
  $scope

  user
)->
  $scope.user= user.data
  $scope.states= 
    'mypage.index':
      icon: 'icons/desk.gif'
      title: 'MYPAGE'
    "#{process.env.PUBLIC_URL}":
      icon: 'icons/search.gif'
      title: 'TOP'

module.exports.resolve=
  user: (mypageId,$http,$state)->
    $http.get '/mypage/user/?mypage_id='+mypageId

  artworks: (user,$http)->
    $http.get '/front/artworks/'+user.data.id