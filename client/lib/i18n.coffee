module.exports.client= (app)->
  app.config ($localStorageProvider,$translateProvider)->
    $translateProvider.useStaticFilesLoader
      prefix: 'i18n/locale-'
      suffix: '.yml'

    {i18n}= $localStorageProvider.$get()
    i18n?= 'ja'
    $translateProvider.use i18n

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
    
