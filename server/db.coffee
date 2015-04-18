# Dependencies
env= require './env'
Sequelize= require 'sequelize'

# Setup sequelize
db= new Sequelize env.DB_NAME,'root',null,
  host: env.DB.split(':')[0]
  port: env.DB.split(':')[1]

  define:
    charset:'utf8'
    collate:'utf8_general_ci'
    underscored: on
  logging: env.NODE_ENV isnt 'production'

module.exports= db