# Dependencies
env= require './env'
db= require env.DB_ROOT

express= require 'express'
multer= require 'multer'
expressSession= require 'express-session'
expressSessionStore= new expressSession.MemoryStore
passport= require './passport'

# Setup express
app= express()
app.use multer()
app.use expressSession
  store: expressSessionStore
  secret: 'keyboard cat'
  httpOnly: no
  resave: yes
  saveUninitialized: yes
app.use passport.initialize()
app.use passport.session()

app.use (req,res,next)->
  # edgy.website -> edgy.black
  return res.redirect env.PUBLIC_URL if req.headers.host is env.MYPAGE_HOST
  next()

app.use express.static env.PUBLIC+'/public'
app.use '/storage',express.static env.STORAGE

module.exports= app