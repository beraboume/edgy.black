module.exports.client= (app)->
  urlPattern= /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi;
  # ref: http://stackoverflow.com/questions/14692640/angularjs-directive-to-replace-text

  app.directive 'parseUrl',->
    restrict: 'A'
    require: 'ngModel'
    scope: ngModel: '=ngModel'
    link: (scope,element,attrs)->
      scope.$watch 'ngModel',(text)->
        return if not text?

        keys=
          '<':'&lt;'
          '>':'&gt;'
          '"':'&quot;'
          '\'':'&apos;'
        text= text.replace /([<>"'])/g,(key)-> keys[key]
        text= text.replace urlPattern,'<a href="$&" target="_blank">$&</a>'
        element.html text
