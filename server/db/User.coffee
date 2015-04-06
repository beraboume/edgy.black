# Dependencies
db= require '../db'
Sequelize= db.constructor

User= db.define 'User',
  twitter_id: Sequelize.BIGINT
  mypage_id:
    type: Sequelize.STRING(40).BINARY
    allowNull: yes
    unique: yes

  name:
    type: Sequelize.STRING(40)
    allowNull: no
  bio:
    type: Sequelize.TEXT
User.belongsTo require './Storage'

module.exports= User