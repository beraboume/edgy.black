module.exports.client= (app)->
  app.config (
    $localStorageProvider
    $translateProvider
    $windowProvider
  )->
    $translateProvider.useStaticFilesLoader
      prefix: 'i18n/locale-'
      suffix: '.yml'
    $translateProvider.preferredLanguage 'ja'
    $translateProvider.fallbackLanguage 'en'

    {i18n}= $localStorageProvider.$get()
    if not i18n?
      i18n= 'en'
      i18n= 'ja' if $windowProvider.$get().navigator.language.slice(0,2) is 'ja'
    $translateProvider.use i18n

  app.directive 'amCalendar',($filter)->
    restrict: 'A'
    link: (scope,element,attrs)->
      amCalendar= (utc)->
        localed= $filter('amCalendar') utc
        localed= localed.replace '前週','先週'
        localed= localed.replace '午前12時','午前0時'
        localed= localed.replace '午後12時','午前12時'
        localed
      utc= attrs.amCalendar
      
      element.text amCalendar utc
      scope.$on 'amMoment:timezoneChanged',->
        element.text amCalendar utc

module.exports.server= (app)->
  path= require 'path'
  YAML= require 'yamljs'

  app.use '/i18n',(req,res,next)->
    filePath= path.join process.env.ROOT,'client','i18n',req.url
    try
      res.json YAML.load filePath
    catch error
      console.error error
      next()
    
