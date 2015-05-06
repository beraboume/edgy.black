# Dependencies
env= require './env'
db= require env.DB_ROOT

path= require 'path'
execSync= (require 'child_process').execSync

# Setup og
module.exports.storage= (req,res,next)->
  bot= null

  ua= req.headers['user-agent']
  bot?= ua.match key for key in ['Twitterbot','Googlebot']
  bot?= req.query.bot?
  return next() if not bot

  {key}= req.params
  filePath= path.join env.STORAGE,key
  res.type 'png'
  res.end execSync "cat #{filePath} | convert - -sample 1000% -format png -"
