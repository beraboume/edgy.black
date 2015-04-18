module.exports.client= (app)->
  app.constant 'components',
    'front.index': '/'

    'front.add': '/add'
    'front.view': '/{id:[0-9]+}'
    'front.view.remove': '/:comment_id/remove'
    'front.edit': '/{id:[0-9]+}/edit'
    'front.remove': '/{id:[0-9]+}/remove'
    
    'front.timeline': '/timeline'
    'front.timeline.remove': '/:comment_id/remove'
    
    'front.mypage': '/mypage'
    'front.mypage.stats': '/stats/:type'
    'front.mypage.edit': '/edit'
    'front.mypage.quit': '/quit'

    'front.help': '/help'

    'mypage.index': '/'

  app.constant 'mypageId',location.hostname.split('.')[0]

  app.config ($locationProvider,$stateProvider,components)->
    $locationProvider.html5Mode true

    $stateProvider.state 'front',
      abstruct: yes
      templateUrl: '/components/front.jade'
      resolve: require('components/front').resolve
      controller: require('components/front').client

    $stateProvider.state 'mypage',
      abstruct: yes
      templateUrl: '/components/mypage.jade'
      resolve: require('components/mypage').resolve
      controller: require('components/mypage').client

    area= 'front'
    area= 'mypage' if location.hostname.split('.').length > 2
    for stateName,url of components when stateName.indexOf(area) is 0
      path= stateName.split '.'
      path.unshift 'components'
      templateUrl= '/'+path.join '/'

      componentPath= templateUrl.slice 1
      controller= undefined
      resolve= undefined
      try
        component= require componentPath
        controller= component.client if component.client?
        resolve= component.resolve if component.resolve?
      catch
        component= undefined
        controller= undefined
        resolve= undefined

      # console.log stateName,url,templateUrl,typeof controller,typeof resolve

      $stateProvider.state stateName,{url,controller,templateUrl,resolve}

    $stateProvider.state 'i18n',
      templateProvider: (
        $localStorage

        $translate
        amMoment

        $state
      )->
        i18n= $localStorage.i18n
        if i18n isnt 'en'
          i18n= 'en'
        else
          i18n= 'ja'
        $localStorage.i18n= i18n
        
        $translate.use i18n
        amMoment.changeLocale i18n

        timezone= 'America/New_York'
        timezone= 'Asia/Tokyo' if $localStorage.i18n is 'ja'
        amMoment.changeTimezone timezone

        $state.reload()

    $stateProvider.state 'glitch',
      templateProvider: (jaggy)->
        if jaggy.glitch is 4
          glitch= ~~(6*Math.random())+1
          glitch= 3 if glitch is 4
          jaggy.glitch= glitch
        else
          jaggy.glitch= 4

        console.log jaggy.glitch

        $state.reload()

    $stateProvider.state 'error',
      url: '*path'
      templateUrl: '/components/.error/index'
      controller: require('components/.error/index').client

module.exports.server= (app)->
  # Dependencies
  fs= require 'fs'
  lookup= require "#{process.env.UTILS_ROOT}/lookup"

  # Setup components
  app.use (req,res,next)->
    filePath= lookup req
    return next() if req.accepts().join() isnt 'text/html' # via ui-router
    return next() if not fs.existsSync filePath # notfound

    res.render filePath