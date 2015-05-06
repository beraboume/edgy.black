# Dependencies
db= require '../db'
Sequelize= db.constructor

Favorite= db.define 'Favorite'
Favorite.belongsTo require './User'

module.exports= Favorite