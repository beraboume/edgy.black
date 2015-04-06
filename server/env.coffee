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

env.consumerKey?= 'J2XKCX0KqCrEG7JjpsrpvTbFS'
env.consumerSecret?= 'J3D8FzAtkns2mJeYVbtgAPrBKHh7jzHMsD44D5der1irmBZlkg'
env.accessToken?= '3139954207-7y1SEuPGe3iErsSLxaRp5pfgZ0MX871gI67MJXj'
env.accessSecret?= 'rSY05eIlUnCqDKTeq2hZcWvamGxGhIpXI5qHP6syWPkG7'

module.exports= env