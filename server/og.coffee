# Dependencies
env= require './env'
db= require env.DB_ROOT

path= require 'path'
execSync= (require 'child_process').execSync

# Setup og
module.exports.artwork_view= (req,res,next)->
  bot= null

  ua= req.headers['user-agent']
  bot?= ua.match key for key in ['Twitterbot','Googlebot']
  bot?= req.query.bot?
  return next() if not bot

  {id}= req.params
  {Artwork,Storage,User}= db.models
  Artwork.find
    where: {id}
    include: [Storage,User]
  .then (artwork)->
    return res.status(404).json null if artwork is null
    res.render 'og',
      title_for_head: 'EDGY.BLACK'
      card: 'summary'
      site: '@edgy_black'
      creator: artwork.User.name
      title: artwork.title
      description: artwork.description
      image: artwork.Storage.url
      url: "#{env.PUBLIC_URL}#{id}"
      domain: env.HOST
  .catch ->
    res.status 400
    res.json null

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