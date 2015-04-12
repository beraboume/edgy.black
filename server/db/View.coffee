# Dependencies
db= require '../db'
Sequelize= db.constructor

View= db.define 'View',
  date: Sequelize.DATE
  count: Sequelize.INTEGER
View.belongsTo require './User'

module.exports= View