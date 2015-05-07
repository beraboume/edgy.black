app= angular.module 'app',[
  'ui.router'
  
  'ngAnimate'
  'angularFileUpload'
  'angularMoment'

  'ngReel'
  'jaggy'
  'webcolor'

  'ngStorage'
  'pascalprecht.translate'
]

(require 'lib/coffee/i18n').client app
(require 'lib/coffee/routes').client app
(require 'lib/coffee/parse-url').client app
(require 'lib/coffee/favorite').client app
app.filter 'keyLength',->
  (object)->
    Object.keys(object).length

app.run (
  $rootScope
  $templateCache

  $state
  $stateParams

  $window
  $timeout
  $webcolorLoadingBar
  $location

  amMoment
  $localStorage
)->
  $rootScope.$state= $state
  $rootScope.$stateParams= $stateParams
  $rootScope.$watch '$state.current.name',(newValue)->
    $rootScope.$state.current.nameClass= $state.current.name.replace /\./g,'-'

  $rootScope.back= ->
    $window.history.back()
  $rootScope.goto= (stateName)->
    try
      $state.transitionTo stateName,$state.params
    catch
      return
  $rootScope.location= (url)->
    $window.location.href= url

  $window.addEventListener 'scroll',->
    $rootScope.scrollY= $window.scrollY
    $rootScope.$apply()

  $rootScope.$on '$stateChangeStart',(event)->

    $webcolorLoadingBar.start()
  $rootScope.$on '$stateChangeSuccess',->
    $webcolorLoadingBar.complete()
    $timeout (->$rootScope.pullToRefresh= no),1000
  $rootScope.$on '$stateChangeError',(event,toState,toParams,fromState,fromParams,error)->
    $webcolorLoadingBar.complete()
    $state.go 'error' if error.status is 404

  $rootScope.title= 'EDGY.BLACK(α)'
  $rootScope.$on '$viewContentLoading',->
    $rootScope.meta= {}
  $rootScope.$on '$viewContentLoaded',->
    renderedTemplate= $window.document.body.innerHTML.trim().length>0
    if renderedTemplate
      $rootScope.meta['og:site_name']?= $rootScope.title
      $rootScope.meta['og:title']?= $state.current.name
      $rootScope.meta['og:url']?= $location.absUrl()
      # $rootScope.meta['og:type']?= 'article'
      $rootScope.meta['og:description']?= angular.element($window.document.body).text()

      $window.expressTurnoutRendered()

  if not $localStorage.i18n?
    language= navigator.language ? navigator.browserLanguage
    $localStorage.i18n=
    if language.slice(0,2) is 'ja'
      'ja'
    else
      'en'
  amMoment.changeLocale $localStorage.i18n

  timezone= 'America/New_York'
  timezone= 'Asia/Tokyo' if $localStorage.i18n is 'ja'
  amMoment.changeTimezone timezone

