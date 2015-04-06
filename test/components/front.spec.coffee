app= require process.cwd()
env= require process.cwd()+'/server/env'
edgy= black: env.PUBLIC_URL
edgy.twitter= pw:(new Buffer process.env.EDGY_BLACK_TWITTER,'base64').toString()

fs= require 'fs'
path= require 'path'

describe 'edgy.black',->
  xdescribe 'guest',->
    describe 'front.index',->
      beforeEach ->
        browser.get '/'
        browser.waitForAngular()

      artworks= element.all By.repeater "artwork in filtered= (artworks|filter:words)"
      words= element By.model "words"

      it 'GET /front/artworks',->
        expect(artworks.count()).toBeLessThan 50

        words.sendKeys 'hogekosan'
        expect(artworks.count()).toEqual 0

      it 'GET /front/artworks/:word',->
        result= element By.tagName 'form'

        words.sendKeys 'hogekosan',protractor.Key.ENTER
        expect(artworks.count()).toEqual 0
        expect(result.getText()).toMatch '…存在しない'

    describe 'front.add',->
      it 'GET /add',->
        browser.get '/add'
        expect(browser.getCurrentUrl()).toEqual "#{edgy.black}mypage"

    describe 'front.view',->
      it 'GET /1/',->
        browser.get '/1/'

        h1= element By.tagName 'h1'
        expect(h1.getText()).toEqual "404 Not Found"

    describe 'front.edit',->
      it 'GET /1/edit',->
        browser.get '/1/edit'

        h1= element By.tagName 'h1'
        expect(h1.getText()).toEqual "404 Not Found"

    describe 'front.remove',->
      it 'GET /1/remove',->
        browser.get '/1/remove'

        h1= element By.tagName 'h1'
        expect(h1.getText()).toEqual "404 Not Found"
      
    describe 'front.mypage',->
      it 'GET /mypage',->
        browser.get '/mypage'
        browser.waitForAngular()

        body= element By.tagName 'body'
        expect(body.getText()).toMatch "ゲスト！"

    describe 'front.mypage.edit',->
      it 'GET /mypage/edit',->
        browser.get '/mypage/edit'
        expect(browser.getCurrentUrl()).toEqual "#{edgy.black}mypage"
        
    describe 'front.mypage.quit',->
      it 'GET /mypage/quit',->
        browser.get '/mypage/quit'
        expect(browser.getCurrentUrl()).toEqual "#{edgy.black}mypage"

  describe 'user',->
    describe 'Authorize via front.mypage',->
      it 'GET /mypage/auth',->
        browser.ignoreSynchronization= on
        browser.get '/mypage/auth'

        id= element By.id 'username_or_email'
        pw= element By.id 'password'

        id.sendKeys 'edgy_black'
        pw.sendKeys edgy.twitter.pw, protractor.Key.ENTER
        .then ->
          browser.ignoreSynchronization= off
          body= element By.tagName 'body'

          expect(body.getText()).toMatch 'やうこそ、'
          expect(browser.getCurrentUrl()).toEqual "#{edgy.black}mypage"

    describe 'CRUD artwork',->
      it 'Create via /add',->
        browser.get '/add'
        browser.waitForAngular()

        title= element By.model 'artwork.title'
        description= element By.model 'artwork.description'
        submit= element By.buttonText 'はい'

        filePath= path.resolve __dirname,'fixture.png'
        fileBase64= fs.readFileSync(filePath).toString('base64')
        uploadScript= """
        var buffer= atob('#{fileBase64}');
        var bufferView= new Uint8Array(buffer.length);
        for(var i=0; i<buffer.length; i++){
          bufferView[i]= buffer.charCodeAt(i);
        }

        var file= new File([new Blob([bufferView])],'fixture.png',{type:'image/png'});
        angular.element(document.querySelector('[ng-model=\"files\"]')).scope().files.push(file);
        angular.element(document.querySelector('[ng-model=\"files\"]')).scope().$apply();
        """

        title.sendKeys 'hogekosan'
        description.sendKeys 'forever'
        browser.executeScript uploadScript

        EC= protractor.ExpectedConditions
        browser.wait EC.visibilityOf submit,10000
        .then ->
          submit.click()
          expect(browser.getCurrentUrl()).toEqual "#{edgy.black}1"

      it 'Read via /1',->
        browser.get '/1'
        browser.waitForAngular()

        expect(browser.getCurrentUrl()).toEqual "#{edgy.black}1"

      it 'Update via /1/edit',->
        browser.get '/1/edit'
        browser.waitForAngular()

        description= element By.model 'artwork.description'
        description.clear()
        description.sendKeys 'infinate'

        title= element By.model 'artwork.title'
        title.clear()
        title.sendKeys 'fugakosan',protractor.Key.ENTER
        .then ->
          expect(browser.getCurrentUrl()).toEqual "#{edgy.black}1"

          h2= element By.tagName 'h2'
          expect(h2.getText()).toEqual "fugakosan"

          pre= element By.tagName 'pre'
          expect(pre.getText()).toEqual "infinate"

      it 'Delete via /1/remove',->
        browser.get '/1/remove'
        browser.waitForAngular()

        submit= element By.buttonText 'ええよ'
        browser.actions().mouseMove(submit).click().perform()
        .then ->
          expect(browser.getCurrentUrl()).toEqual "#{edgy.black}"

          browser.get '/1'
          h1= element By.tagName 'h1'
          expect(h1.getText()).toEqual "404 Not Found"
