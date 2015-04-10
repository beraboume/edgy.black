> [edgy.black](http://edgy.black/)

# TODO
* テストをていねいに書く
* ng-messagesのインストールと実装
  * マイページURLの重複チェック
* バージョンアップ・障害情報
* <del>ng-translateのインストールと実装</del>

* jpg,png,gif以外のアップロード
  * -> image/canvasを経由して無理やりpngに変換する？

* 動作確認
  * win/mac 動作保証ブラウザの明記
* スペシャルサンクス 利用素材の明記

# Setup for docker
```bash
$ brew install boot2docker
$ boot2docker init # may sudo
$ boot2docker start

$ docker run --name edgy.black -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql
$ docker exec -it edgy.black mysql -u root -p
# root

mysql $ create database edgy_test;
# Query OK, 1 row affected (0.00 sec)

mysql $ SET PASSWORD = PASSWORD('');
# Query OK, 0 rows affected (0.00 sec);

mysql $ exit
# Bye

# Set env a twitter login password
$ echo -n 'rawpassword' | base64
# ######

$ vim ~/.bash_profile
# export EDGY_BLACK_TWITTER=######
$ source ~/.bash_profile

$ nodebrew use v0.12.0
$ npm test
```

> https://registry.hub.docker.com/_/mysql/
> https://docs.saucelabs.com/ci-integrations/travis-ci/
