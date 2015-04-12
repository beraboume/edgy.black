# Dependencies
db= require '../db'
Sequelize= db.constructor

Artwork= db.define 'Artwork',
  title:
    type: Sequelize.STRING
    allowNull: no

  description:
    type: Sequelize.TEXT
    allowNull: no

  storage_key: Sequelize.UUID
Artwork.belongsTo require './User'
Artwork.belongsTo require './Storage'
Artwork.hasMany require './View'

module.exports= Artwork