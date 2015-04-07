# Dependencies
env= process.env

# Setup environment
env.PORT?= 59798
env.ROOT?= process.cwd()

env.SERVER_ROOT?= __dirname

env.DB?= '192.168.59.103:3306'
env.DB_ROOT?= __dirname+'/db'

env.PUBLIC?= 'client'
env.PUBLIC_URL?= "http://localhost:#{process.env.PORT}/"
env.MYPAGE_HOST?= "localhost.com:59798"

env.STORAGE?= env.ROOT+'/storage'
env.STORAGE_URL?= "#{env.PUBLIC_URL}storage/"

env.consumerKey?= '2AuSobZWQOxAhECduhlpcQtgy'
env.consumerSecret?= 'KNYGQ95VGmbJiXkZHbtKcwJp8gzhifLAoCr5sKUEiXKbsp98i0'
env.accessToken?= '3139954207-gWTXspc8FejKnzMcny1dtqRQAVaSB3iynPkrH4t'
env.accessSecret?= 'vigWSkGpFG4KJfQLtUoMkJkiSDwWfsDiV7GodDTdwTUNA'

module.exports= env