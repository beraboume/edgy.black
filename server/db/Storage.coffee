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

  user_id: Sequelize.INTEGER

module.exports= Storage