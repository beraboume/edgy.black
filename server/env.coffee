# Dependencies
env= process.env

# Setup environment
env.PORT?= 59798
env.ROOT?= process.cwd()

env.SERVER_ROOT?= __dirname

env.DB?= '192.168.59.103:3306'
env.DB_NAME?= 'edgy_test'
env.DB_ROOT?= __dirname+'/db'

env.PUBLIC?= 'client'
env.PUBLIC_URL?= "http://localhost:#{process.env.PORT}/"
env.MYPAGE_HOST?= "localhost.website:59798"

env.STORAGE?= "#{env.ROOT}/storage"
env.STORAGE_URL?= "#{env.PUBLIC_URL}storage/"

env.consumerKey?= '9HXBAI0QuA5BkOyydci3Jw4n5'
env.consumerSecret?= 'v8hGsLlSlYEnDbyipE4w7k8x6bsxCY4TLUxikfazS1S8gRm6Or'
env.accessToken?= '3150694044-Jdx5iAJFYolGW9IuCUhR64KcgxG2ThAlyJVUzP3'
env.accessSecret?= 'ok5oXFot60YmeQSA4cSPZB9zvK7QWBXKJ5wmbucT8CKOA'

module.exports= env