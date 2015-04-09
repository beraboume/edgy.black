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

env.STORAGE?= env.ROOT+'/storage'
env.STORAGE_URL?= "#{env.PUBLIC_URL}storage/"

env.consumerKey?= '2AuSobZWQOxAhECduhlpcQtgy'
env.consumerSecret?= 'KNYGQ95VGmbJiXkZHbtKcwJp8gzhifLAoCr5sKUEiXKbsp98i0'
env.accessToken?= '3139954207-YgbSAg7B16mbRxyaAgkWHQoEw2ddDGwuPU25i70'
env.accessSecret?= 'AwQPB93wb9ZYRLEBkDWuMezvJEFXdMk8ACbjuLtW5DDrI'

module.exports= env