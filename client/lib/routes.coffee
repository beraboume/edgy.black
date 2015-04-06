module.exports.client= (app)->
  app.config ($locationProvider,$stateProvider,components)->
    $locationProvider.html5Mode true

    $stateProvider.state 'front',
      abstruct: yes
      templateUrl: '/components/front.jade'
      resolve: require('./components/front').resolve
      controller: require('./components/front').client

    $stateProvider.state 'mypage',
      abstruct: yes
      templateUrl: '/components/mypage.jade'
      resolve: require('./components/mypage').resolve
      controller: require('./components/mypage').client

    area= 'front'
    area= 'mypage' if location.hostname.split('.').length > 2
    for stateName,url of components when stateName.indexOf(area) is 0
      path= stateName.split '.'
      path.unshift 'components'
      templateUrl= '/'+path.join '/'

      componentPath= '.'+templateUrl
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

      console.log stateName,url,templateUrl,typeof controller,typeof resolve

      $stateProvider.state stateName,{url,controller,templateUrl,resolve}

    $stateProvider.state 'error',
      url: '*path'
      templateUrl: '/components/.error/index'
      controller: require('./components/.error/index').client

  app.constant 'mypageId',location.hostname.split('.')[0]
  app.constant 'components',
    'front.index': '/'

    'front.add': '/add'
    'front.view': '/{id:[0-9]+}'
    'front.edit': '/{id:[0-9]+}/edit'
    'front.remove': '/{id:[0-9]+}/remove'
    
    'front.mypage': '/mypage'
    'front.mypage.edit': '/edit'
    'front.mypage.quit': '/quit'

    'mypage.index': '/'

module.exports.server= (app)->
  # Dependencies
  fs= require 'fs'
  path= require 'path'

  # Setup components
  app.use (req,res,next)->
    fileName= req.url.slice(1) or 'index'
    fileName= path.join fileName,'index' if fileName.slice(-1) is '/'
    fileName+= '.jade' if fileName.indexOf('.jade') is -1

    filePath= fileName
    filePath= path.join process.env.ROOT,process.env.PUBLIC,filePath

    # console.log filePath

    return next() if req.accepts().join() isnt 'text/html' # via ui-router
    return next() if not fs.existsSync filePath # notfound

    res.render filePath