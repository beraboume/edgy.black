# Dependencies
db= require '../db'
Sequelize= db.constructor

Comment= db.define 'Comment',
  body:
    type: Sequelize.STRING(140)
    allowNull: no
Comment.belongsTo require './Artwork'
Comment.belongsTo require './User'

module.exports= Comment