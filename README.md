> [edgy.black](http://edgy.black/)

# TODO
## オレオレ要望（上ほど優先）

* storageディレクティブ遅い（リクエスト送りすぎ）

* スライドショーが欲しい
* へんしゅうで画像のアップロードし直したい（jaggyキャッシュ消す）
* <del>コメント削除</del>
* 文章内のURLへ、自動リンク生成
* かっこいいアラートメッセージ（swalはborder-radius使っててEDGEじゃない）
* ヒストリー（投稿履歴・閲覧数○○オーバーなど）
* けんさくけっか・マイページさくひん一覧（文字情報多めの画像検索ページを作る）
* ランキング
* 公開範囲（自分のみ／マイページのみ／すべて）
* ライセンス（転載禁止etc…過去デザイン参照）

## 下げられた優先度（めんどくさい）
* IE10許すまじ
  * BitmapManiaフォントが使えない（代替フォントを指定する。可能であれば、eotで表示できるようにする）
  * angular-webcolorで画面全体の座標が動く
  * マイページでスクロールバーが二重に出る

* ng-messagesのインストールと実装
* テストをていねいに書く
* クローラー
  * 404返しちゃまずい所が結構ある

> 昔作ったデザイン
> https://dl.dropboxusercontent.com/u/22608895/edgy/index.html

# Engine
$ nodebrew use v0.12.0

## Setup docker for OSX
```bash
$ brew install boot2docker
$ boot2docker init # may sudo
$ boot2docker up # may sudo
```

## Setup redis by docker
```bash
$ docker run -d --name edgy.redis -p 6379:6379 redis
# edgy.redis
```

## Setup mysql by docker
```bash
$ docker run --name edgy.black -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql
# edgy.black

$ docker exec -it edgy.black mysql -u root -p
# Type: root

mysql $ create database edgy_test;
# Query OK, 1 row affected (0.00 sec)

mysql $ SET PASSWORD = PASSWORD('');
# Query OK, 0 rows affected (0.00 sec);

mysql $ exit
# Bye
```

## Setuped
```bash
$ docker ps -a
# ... IMAGE        ... PORTS                  NAMES
# ... redis:3      ... 0.0.0.0:6379->6379/tcp edgy.redis
# ... mysql:latest ... 0.0.0.0:3306->3306/tcp edgy.black
```

## Setup password for test
```bash
# Set env a twitter login password
$ echo -n 'rawpassword' | base64
# ######

$ vim ~/.bash_profile
# export EDGY_BLACK_TWITTER=######
$ source ~/.bash_profile

$ npm test
```

>
  * https://registry.hub.docker.com/_/mysql/
  * https://registry.hub.docker.com/_/redis/
  * https://docs.saucelabs.com/ci-integrations/travis-ci/
