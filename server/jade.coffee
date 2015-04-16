# Dependencies
env= require './env'
app= require './express'

debug= (require 'debug') 'edgy:server'

jade= require 'jade'

stylus= require 'stylus'
koutoSwiss= require 'kouto-swiss'

browserifyBin= require.resolve 'browserify/bin/cmd.js'
wanderer= require 'wanderer'
path= require 'path'
execSync= require('child_process').execSync

# Setup jade
app.set 'view engine','jade'
app.set 'views',env.PUBLIC
app.locals.basedir= env.PUBLIC
app.locals.pretty= env.NODE_ENV isnt 'production'

# Setup jadeFilters
jade.filters.stylus= (str,options)->
  css= ''

  stylus str
  .set 'paths',[env.PUBLIC]
  .set 'compress',env.NODE_ENV is 'production'
  .use koutoSwiss()
  .render (error,rendered)->
    throw error if error?

    css= rendered

  css
jade.filters.coffeeify= (str,options)->
  filename= options.filename
  script= "#{browserifyBin} #{filename}"
  script+= " -t coffeeify --extension .coffee --no-bundle-external"
  script+= " --no-detect-globals"# Fix "new Buffer"

  debug script

  # Setup client-side javascript
  componentFiles= ['**/*.coffee','components/.error/*.coffee']
  components= wanderer.seekSync componentFiles,cwd:env.PUBLIC
  for component in components
    expose= path.relative "./",component
    expose= expose.slice 0,expose.length-7 # .coffee

    debug ' -r ./'+env.PUBLIC+'/'+component+':'+expose
    script+= ' -r ./'+env.PUBLIC+'/'+component+':'+expose

  execSync(script).toString()

module.exports= jade