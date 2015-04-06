app= angular.module 'app',[
  'ui.router'
  
  'ngAnimate'
  'ngReel'

  'angularFileUpload'
  'angularMoment'

  'jaggy'
  'webcolor'
]

(require './lib/storage').client app
(require './lib/routes').client app

app.run (
  $rootScope
  $state

  $window
  $webcolorLoadingBar

  $templateCache

  amMoment
)->
  amMoment.changeLocale 'ja'

  $rootScope.back= ->
    $window.history.back()
  $rootScope.goto= (stateName)->
    try
      $state.transitionTo stateName,$state.params
    catch
      return
  $rootScope.location= (url)->
    $window.location.href= url
  $rootScope.$state= $state
  $rootScope.notfoundSVG= 'data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMSAxIiBzaGFwZS1yZW5kZXJpbmc9ImNyaXNwRWRnZXMiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+PHBhdGggZD0iTTAsMGgxdjFoLTFaIiBmaWxsPSJyZ2JhKDAsMCwwLDAuNTApIj48L3BhdGg+PC9zdmc+'

  pullToRefresh= no
  $window.addEventListener 'scroll',->
    $rootScope.scrollY= $window.scrollY
    $rootScope.$apply()

    if not pullToRefresh and $rootScope.scrollY < -60
      pullToRefresh= yes

      $state.reload()
  $rootScope.$on '$stateChangeStart',(event)->

    $webcolorLoadingBar.start()
  $rootScope.$on '$stateChangeSuccess',->
    $webcolorLoadingBar.complete()
    setTimeout (->pullToRefresh= no),1000
  $rootScope.$on '$stateChangeError',(event,toState,toParams,fromState,fromParams,error)->
    $webcolorLoadingBar.complete()
    $state.go 'error' if error.status is 404

  $rootScope.$on '$viewContentLoaded',->
    $templateCache.removeAll()