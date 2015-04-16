# Dependencies
env= require './server/env'
wanderer= require 'wanderer'

debug= (require 'debug') 'edgy'

# Setup express
app= require './server/express'
jade= require './server/jade'

# Setup routes and middlewares
components= wanderer.seekSync env.PUBLIC+'/lib/**/*.coffee'
components= components.concat wanderer.seekSync env.PUBLIC+'/components/**/*.coffee'
components= components.concat wanderer.seekSync env.PUBLIC+'/components/.error/*.coffee'
for filename in components
   component= require "./#{filename}"
   component.server app if component.server?

   debug "./#{filename}"

# Setup sequelize
db= require './server/db'
models= wanderer.seekSync 'server/db/*.coffee',cwd:__dirname
defined= require './'+model for model in models

options= force:yes if process.env.JASMINETEA_ID?
db.sync options
.then ->
  app.listen env.PORT

  console.log 'Successfully setup.'
  console.log 'Server running at',env.PUBLIC_URL