# Dependencies
env= require './env_secret'

# Setup environment
env.PORT?= 59798
env.ROOT?= process.cwd()

env.SERVER_ROOT?= __dirname
env.UTILS_ROOT?= env.SERVER_ROOT+'/utils'

env.DB?= '192.168.59.103:3306'
env.DB_NAME?= 'edgy_test'
env.DB_ROOT?= __dirname+'/db'

env.PUBLIC?= 'client'
env.PUBLIC_URL?= "http://localhost:#{process.env.PORT}/"
env.MYPAGE_HOST?= "localhost.website:59798"

env.STORAGE?= "#{env.ROOT}/storage"
env.STORAGE_URL?= "#{env.PUBLIC_URL}storage/"

module.exports= env