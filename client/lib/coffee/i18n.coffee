module.exports.client= (app)->
  app.config (
    $localStorageProvider
    $translateProvider
    $windowProvider
  )->
    $translateProvider.useStaticFilesLoader
      prefix: 'i18n/locale-'
      suffix: '.json'
    $translateProvider.preferredLanguage 'ja'
    $translateProvider.fallbackLanguage 'en'

    {i18n}= $localStorageProvider.$get()
    if not i18n?
      i18n= 'en'
      i18n= 'ja' if $windowProvider.$get().navigator.language.slice(0,2) is 'ja'
    $translateProvider.use i18n

  app.directive 'published',($filter)->
    restrict: 'A'
    link: (scope,element,attrs)->
      utc= attrs.published
      format= (utc)->
        localed= $filter('amDateFormat') utc,'llll'

        localed= localed.replace '前週','先週'
        localed= localed.replace '午前12時','午前0時'
        localed= localed.replace '午後12時','午前12時'

        element.text localed
        element.attr 'title',$filter('amTimeAgo') utc
      
      format utc
      scope.$on 'amMoment:timezoneChanged',->
        format utc

module.exports.server= (app)->
  path= require 'path'
  YAML= require 'yamljs'

  app.use '/i18n',(req,res,next)->
    filePath= process.env.ROOT+'/client/public/i18n'+req.url
    filePath= filePath.replace '.json','.yml'# Avoid conflicts with express.static
    try
      res.json YAML.load filePath
    catch error
      console.error error
      next()
    