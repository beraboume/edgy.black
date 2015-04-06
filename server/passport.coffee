# Dependencies
env= require './env'
db= require env.DB_ROOT

debug= (require 'debug') 'edgy:server'

passport= require 'passport'
passportConfig=
  twitter:
    consumerKey: env.consumerKey
    consumerSecret: env.consumerSecret
    callbackURL: "#{env.PUBLIC_URL}callback"
TwitterStrategy= require('passport-twitter').Strategy

crypto= require 'crypto'

# Setup passport
passport.serializeUser (user,done)-> done null,user
passport.deserializeUser (obj,done)-> done null,obj
passport.use new TwitterStrategy passportConfig.twitter,(token,tokenSecret,profile,done)->
  user= null

  {User}= db.models
  User.findOrCreate
    where:
      twitter_id: profile.id
    defaults:
      name: profile.displayName
      bio: profile._json?.description

  .then (result)->
    user= result[0]
    user.isNewbie= result[1]

    debug 'authorized',user

    if user.isNewbie
      return User.find
        where:
          mypage_id: profile.username
      .then (existsUser)->
        user.mypage_id= profile.username
        user.mypage_id= crypto.createHash('sha1').update(profile.id).digest('hex') if existsUser?

        user.save()
    return

  .then ->
    done null,user.dataValues
  .catch (error)->
    done error

module.exports= passport