# Dependencies
env= require './env'
db= require env.DB_ROOT

# Setup og
module.exports= (req,res,next)->
  bot= null

  ua= req.headers['user-agent']
  bot?= ua.match key for key in ['Twitterbot','Google']
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
      card: 'summary_large_image'
      site: '@edgy_black'
      creator: artwork.User.name
      title: artwork.title
      description: artwork.description
      image: artwork.Storage.url
      url: "#{env.PUBLIC_URL}#{id}"
  .catch ->
    res.status 400
    res.json null