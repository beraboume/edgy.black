# Dependencies
env= require './env'

express= require 'express'
multer= require 'multer'
session= require 'express-session'
SessionStore= require('connect-redis') session
turnout= require 'express-turnout'
passport= require './passport'
og= require './og'

# Setup express
app= express()
app.use (req,res,next)->
  # edgy.website -> edgy.black
  return res.redirect env.PUBLIC_URL if req.headers.host is env.MYPAGE_HOST
  next()
app.use express.static env.PUBLIC+'/public'
app.use '/storage',(req,res,next)->
  res.setHeader 'Access-Control-Allow-Origin','*'
  next()
app.use '/storage/:key',og.storage
app.use '/storage',express.static env.STORAGE
app.use '/:id',og.artwork_view
app.use turnout timeout:5000

# Setup session
app.use session
  store: new SessionStore host:env.DOCKER_IP
  secret: 'keyboard cat'
  httpOnly: no
  resave: yes
  saveUninitialized: yes
app.use passport.initialize()
app.use passport.session()

# Setup multipart/form-data
app.use multer inMemory:yes

module.exports= app