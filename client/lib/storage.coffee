module.exports.client= (app)->
  app.directive 'storage',($http,$compile,jaggy)->
    replace: yes
    link: (scope,element,attrs)->
      {key}= attrs
      return element.replaceWith window.jaggy.emptySVG() if key.length is 0

      $http.get '/storage_url/'+key
      .then (result)->
        url= result.data

        svg= angular.element '<img ng-src="'+url+'" jaggy>'
        element.replaceWith svg 
        $compile(svg)(scope)
      .catch (error)->
        console.log error
        element.replaceWith window.jaggy.emptySVG()

module.exports.server= (app)->
  db= require process.env.DB_ROOT

  app.get '/storage_url/:key',(req,res)->
    {key}= req.params

    {Storage}= db.models
    Storage.find
      where: {key}
    .then (storage)->
      {url,created_at}= storage
      console.log "#{url}?#{created_at?.getTime()}"
      res.end "#{url}?#{created_at}"
    .catch (error)->
      res.status 404
      res.json error.message