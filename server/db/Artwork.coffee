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

  show:
    type: Sequelize.ENUM 'PUBLIC','PRIVATE','SECRET'
    defaultValue: 'PUBLIC'

  storage_key: Sequelize.UUID
Artwork.belongsTo require './User'
Artwork.belongsTo require './Storage'
Artwork.hasMany require './View'
Artwork.hasMany require './Favorite'

# Methods
Artwork.getWhereFromVisible= (id,user_id)->
  conditions= []
  conditions.push
    show: 'PUBLIC'
  conditions.push
    show: 'PRIVATE'
  conditions.push
    show: 'SECRET'
    user_id: user_id

  Sequelize.and {id},Sequelize.or conditions...

module.exports= Artwork