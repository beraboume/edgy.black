# Dependencies
db= require '../db'
Sequelize= db.constructor

Storage= db.define 'Storage',
  key:
    primaryKey: yes
    type: Sequelize.UUID
    defaultValue: Sequelize.UUIDV1

  sha1: Sequelize.STRING(40).BINARY

  mime: Sequelize.STRING
  
  url:
    type: Sequelize.TEXT
    allowNull: no
    get: ->
      url= @getDataValue 'url'
      url+= @getDataValue 'updated_at' if url?
      url

  user_id: Sequelize.INTEGER

module.exports= Storage