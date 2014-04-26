'use strict'

$ = jQuery.noConflict()
$ ->
  # ===================================
  # Globals
  # ===================================

  $win  = $ window
  $doc  = $ document
  $body = $ 'body'
  $html = $ 'html'
  $all  = $ 'html body'

  $html.addClass 'onload'

  # ===================================
  # API
  # ===================================

  # https://wordpress.org/plugins/json-api/other_notes/#1.1.-Requests
  $api =
    domain: ($ '#api').data 'url'

    home: (data = {}) ->
      return $.ajax "#{$api.domain}/?feed=json&callback=callback",
        type: 'GET'
        data: data
        dataType: 'jsonp'

    archive: (data = {}) ->
      return $.ajax "#{$api.domain}/#{data.post_type}/?json=get_posts&page=#{data.page}",
        type: 'GET'
        data: data
        dataType: 'jsonp'

    single: (data = {}) ->
      return $.ajax "#{$api.domain}/#{data.post_type}/?json=get_post&post_id=#{data.post_id}",
        type: 'GET'
        data: data
        dataType: 'jsonp'

  # ===================================
  # UI
  # ===================================

  ui =

    # _pl: [
    #   { p: 'platform', reg: /iphone/i, id: 'iphone' },
    #   { p: 'platform', reg: /ipod/i, id: 'ipod' },
    #   { p: 'userAgent', reg: /ipad/i, id: 'ipad' },
    #   { p: 'userAgent', reg: /blackberry/i, id: 'blackberry' },
    #   { p: 'userAgent', reg: /android/i, id: 'android' },
    #   { p: 'platform', reg: /mac/i, id: 'mac' },
    #   { p: 'platform', reg: /win/i, id: 'windows' },
    #   { p: 'platform', reg: /linux/i, id: 'linux' }
    # ]

    # _ua: null

    # ua: ->
    #   return ui._ua  unless ui._ua is null
    #   return ui._ua = p.id  for p in ui._pl when p.reg.test window.navigator[p.p]

    animationTime: 240

    spinner: (active = no) ->
      if active
        ($ '.ui-spinner').addClass 'ui-spinner-active'
      else
        ($ '.ui-spinner').removeClass 'ui-spinner-active'

    progress: (active = no) ->
      margin = if media.sign_in then 27 else -4
      $progress = $ '.ui-progress'
      if active
        $progress.addClass('ui-progress-active').stop().animate
          top: 0 + margin
        , ui.animationTime
      else
        $progress.stop().animate
          top: -1 * $progress.height() + margin
        , ui.animationTime, ->
          $progress.removeClass 'ui-progress-active'

    scroll:
      swing: (scspeed = 700) ->
        $all.animate scrollTop: 0, scspeed, 'swing'
      fast: ->
        $all.animate scrollTop: 0, 'fast'

    # ページ切り替え
    switch: () ->


    # フォトログ用ポップアップウィンドウ
    popup: ->
      $target = $ '.ui-container'
      $target.addClass 'behind'
      $target.css 'top': "#{0 - $doc.scrollTop()}px"
    releasePopup: ->
      $target = $ '.ui-container'
      $target.removeClass 'behind'
      $target.css 'top': 'auto'

    _datetimeUpdate: null

    # datetimeUpdate: ->
    #   clearInterval ui._datetimeUpdate
    #   ui._datetimeUpdate = setInterval ->
    #     ($ 'time').each (i, el) ->
    #       $el = $ el
    #       $el.html moment($el.attr 'datetime').fromNow()
    #   , 1000 * 10

    # datetime: (date) ->
    #   date = moment date
    #   ui.datetimeUpdate()
    #   return ($ '<time>')
    #     .addClass('ui-datetime')
    #     .attr('datetime', date.toISOString())
    #     .attr('title', date.format('YYYY-MM-DD HH:mm:ss'))
    #     .text(date.fromNow())

    # filesize: (size, unit = 0) ->
    #   units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    #   size = size / 1024 while size > 1024 when ++unit
    #   return "#{(Math.max size, 0.1).toFixed(1)} #{units[unit]}"

    # URLフォーマット
    parse_uri: (uri) ->
      reg = /^(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?/
      m = uri.match(reg)
      if m
        scheme: m[1]
        authority: m[2]
        path: m[3]
        query: m[4]
        fragment: m[5]
      else
        null

    # 日付フォーマット
    parse_date: (datetime) ->
      date = new Date datetime
      month_names = [
        '日', '月', '火', '水', '木', '金', '土'
      ]
      weekday_names = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ]
      return format =
        year: date.getFullYear()
        month: "#{date.getMonth() + 1}月"
        month_en: month_names[date.getMonth() + 1]
        day: date.getDate()
        weekday: weekday_names[date.getDay()]

  # ===================================
  # LocalStorage
  # ===================================

  storage =

    get: (key) ->
      if window.localStorage?
        return window.localStorage.getItem key
      return no

    set: (key, val) ->
      if window.localStorage?
        return window.localStorage.setItem key, val
      return no


  # ===================================
  # Backbone::Account
  # ===================================


  # ===================================
  # Backbone::Photolog Archive
  # ===================================

  class Archive extends Backbone.Model

    defaults: {}

    initialize: ->

  class ArchiveView extends Backbone.View

    tagName: 'div'

    className: 'post-item'

    template: _.template ($ '#tmpl-archive').html()

    events:
      'click': 'navigateToSingle'

    initialize: ->
      @$el.html @template @model.toJSON()

    render: ->
      # console.log '@model: ', @model
      # カスタム投稿タイプ
      @$el.addClass "item-#{@model.get('type')}"
      # カスタム投稿フィールド
      acf = @model.get('acf')
      # data属性
      @$el.data 'id', @model.get('id')
      @$el.data 'href', @model.get('url')
      # 日付アイコン
      date = ui.parse_date @model.get('date')
      (@$ '.date-month').text date.month
      (@$ '.date-day').text date.day
      (@$ '.date-year').text date.year

      # フォトログ
      if @model.get('type') is 'photolog'
        @$el.addClass 'loaded col-xs-6 col-sm-3'
        # サムネイル
        if acf.photo
          (@$ '.post-preview').css
            'background-image': "url('#{acf.photo.sizes.medium}')"
          # (@$ '.tmp').append $img = ($ 'img').addClass('hidden js-load-event').attr('src', acf.photo)
          # (@$ '.js-load-event').on('load', _.bind(@onLoad, @)).each ->
          #   $img.load() if @complete
        # 抜粋文
        if acf.body
          (@$ '.excerpt').text acf.body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

      # 活動レポート
      if @model.get('type') is 'report'
        @$el.addClass 'loaded col-sm-8 col-sm-offset-4 col-xs-12'
        # 抜粋文
        if excerpt = @model.get('excerpt')
          (@$ '.excerpt').text excerpt.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

      # プロジェクト
      if @model.get('type') is 'project'
        @$el.addClass 'loaded col-sm-4 col-xs-12'
        # サムネイル
        if thumbnail = @model.get('thumbnail_images')
          (@$ '.post-preview').css
            'background-image': "url('#{thumbnail.medium.url}')"

      # 抜粋文の短縮
      (@$ '.ellipsis').ellipsis()

      return @

    onLoad: -> # 画像の読み込みが完了した時に発火
      @$el.addClass 'loaded'
      # setTimeout ->
      #   (@$ '.tmp').remove()
      # , 4000

    backToIndex: ->
      $app.navigate '/', yes

    navigateToSingle: ->
      url = ui.parse_uri(@$el.data('href')).path
      $app.navigate url, yes

  # ===================================
  # Backbone::Archives
  # ===================================

  class Archives extends Backbone.Collection

    model: Archive

  class ArchivesView extends Backbone.View

    el: $ '.ui-archive'

    template: _.template ($ '#tmpl-archives').html()

    events: {}

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '.post-items').empty()

    append: (content) ->
      view = new ArchiveView(model: content).render()
      (@$ '.post-items').append view.el

    setTitle: (title) ->
      if title
        (@$ 'hgroup.page-title > h1').html title
        (@$ 'hgroup.page-title').css 'height': 'auto'
      else
        (@$ 'hgroup.page-title > h1').html ''
        (@$ 'hgroup.page-title').css 'height': '0'

  # ===================================
  # Backbone::Single
  # ===================================

  class Single extends Backbone.Model

    defaults: {}

    initialize: ->

  class SingleView extends Backbone.View

    tagName: 'div'

    className: 'post-item'

    template: _.template ($ '#tmpl-single').html()

    events:
      'click .meta-nav-prev': 'navigateToPrevious'
      'click .meta-nav-next': 'navigateToNext'

    initialize: ->
      @$el.html @template @model.toJSON()

    render: ->
      self = @
      # console.log '@model: ', @model
      # カスタム投稿タイプ
      @$el.addClass "item-#{@model.get('type')}"
      # カスタム投稿フィールド
      acf = @model.get('acf')
      # data属性
      @$el.data 'id', @model.get('id')
      @$el.data 'href', @model.get('url')
      # 日付アイコン
      date = ui.parse_date @model.get('date')
      (@$ '.date-month').text date.month
      (@$ '.date-day').text date.day
      (@$ '.date-year').text date.year
      # タグ
      tags = @model.get('tags')
      for tag in tags
        $tag = ($ '<div />').addClass('tag').text tag.title
        (@$ '.ui-tags').append $tag

      # フォトログ
      if @model.get('type') is 'photolog'
        @$el.addClass 'loaded col-xs-12'
        # サムネイル
        if acf.photo
          (@$ '.post-preview').css
            'background-image': "url(\"#{acf.photo.url}\")"
          # $photo = ($ 'img').addClass('hidden js-load-event').attr('src', acf.photo)
          # (@$ '.tmp').append $photo
          # (@$ '.js-load-event').on 'load', _.bind(@onLoad, @)
          # $photo.on 'load', ->
          #   console.log 'loaded!'
          #   self.onLoad()
          # $photo.load() if $photo.complete
        # Google Maps
        maps_url = 'https://www.google.com/maps/embed/v1'
        gmaps_key = 'AIzaSyBvYIaT_tlgQW1BkPX6Afs_MTExY85b1cs'
        position = encodeURIComponent acf.position.address
        (@$ '#g-maps').attr 'src', "#{maps_url}/place?q=#{position}&key=#{gmaps_key}"

      # 活動レポート
      if @model.get('type') is 'report'
        @$el.addClass 'loaded col-sm-8 col-sm-offset-4 col-xs-12'

      # プロジェクト
      if @model.get('type') is 'project'
        @$el.addClass 'loaded col-xs-12'
        # サムネイル
        if thumbnail = @model.get('thumbnail_images')
          (@$ '.post-preview').css
            'background-image': "url('#{thumbnail.large.url}')"

      # Facebook コメント
      (@$ '#fb-comments').attr 'href', @model.get('url')
      (@$ '#fb-like').attr 'href', @model.get('url')
      setTimeout ->
        FB.XFBML.parse() if not (@$ 'fb-comments > span')[0] or not (@$ 'fb-like > span')[0]
      , 400
      # Twitter ボタン
      (@$ '#tw-like').data 'url', @model.get('url')
      (@$ '#tw-like').data 'text', "#{@model.get('url')}"
      setTimeout ->
        twttr.widgets.load() if typeof(twttr) isnt 'undefined'
      , 400
      # Google+ ボタン
      setTimeout ->
        gapi.plusone.go() if typeof(gapi) isnt 'undefined'
      , 400

      return @

    onLoad: -> # 画像の読み込みが完了した時に発火
      @$el.addClass 'loaded'
      # setTimeout ->
      #   (@$ '.tmp').remove()
      # , 4000

    navigateToPrevious: (event) ->
      event.preventDefault()
      url = ui.parse_uri(@model.get('previous_url')).path
      $app.navigate url, yes

    navigateToNext: (event) ->
      event.preventDefault()
      url = ui.parse_uri(@model.get('next_url')).path
      $app.navigate url, yes

  # ===================================
  # Backbone: Singles
  # ===================================

  class Singles extends Backbone.Collection

    model: Single

  class SinglesView extends Backbone.View

    el: $ '.ui-single'

    template: _.template ($ '#tmpl-singles').html()

    events: {}

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '.post-items').empty()

    append: (content) ->
      @collection.reset()
      view = new SingleView(model: content).render()
      (@$ '.post-items').append view.el
      @setTitle content.title

    setTitle: (title) ->
      if title
        (@$ 'hgroup.page-title > h1').html title
        (@$ 'hgroup.page-title').css 'height': 'auto'
      else
        (@$ 'hgroup.page-title > h1').html ''
        (@$ 'hgroup.page-title').css 'height': '0'

  # ===================================
  # Backbone: Layers
  # ===================================

  class Layers extends Backbone.Collection

    model: Single

  class LayersView extends Backbone.View

    el: $ '.ui-layer'

    template: _.template ($ '#tmpl-layers').html()

    events: {}

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '.ui-context-layer').empty()

    append: (content) ->
      @collection.reset()
      view = new SingleView(model: content).render()
      (@$ '.ui-context-layer').append view.el

  # ===================================
  # Backbone::Application
  # ===================================

  class Application extends Backbone.Router

    # el
    $title: $ 'title'
    $search: null

    # state
    ajax: no
    fetching: no
    previous: 'default'
    previous_api: null
    current: 'default'  # report, project, photolog, etc
    current_api: null   # posts, post

    routes:
      '?s=(:text)': 'search'
      '': 'index'

      'project/': 'projects'
      'project/page/:page/': 'projects'
      'project/:year/:month/:post_id/': 'project'

      'report/': 'reports'
      'report/page/:page/': 'reports'
      'report/:year/:month/:post_id/': 'report'

      'photolog/': 'photologs'
      'photolog/page/:page/': 'photologs'
      'photolog/:year/:month/:post_id/': 'photolog'

      'about(/)': 'about'
      'contact(/)': 'contact'
      'publications(/)': 'publications'

    initialize: ->
      @navigate location.pathname, yes
      Backbone.history.start pushState: on
      $ =>
        media.archivesView = new ArchivesView media.archives
        media.singlesView = new SinglesView media.singles
        media.layerView = new LayersView media.layers
        @$title = $ 'title'

    # メニューや画面表示を更新する
    changeMenuTab: ->
      $target = ($ "li.menu-item > a[href='/#{@current}']")
      $target
        .parents('.nav-menu')
        .find('.menu-item')
        .removeClass 'current-menu-item'
      $target
        .parents('.menu-item')
        .addClass 'current-menu-item'
      return
    beforeFetch: ->
      # ロードバー
      @fetching = yes
      ui.progress on
      # ビューをフェードアウト
      ($ '.ui-article > *')
        .not(".ui-#{@current_api}")
        .removeClass 'fade'
      # 上部へスクロール
      if media.query.post_type isnt 'archive' or media.query.page is 1
        ui.scroll.swing()
      # デバッグ
      console.log "API(#{@current_api}) リクエスト準備:", media
    afterFetch: ->
      @fetching = no
      # プログレスバーを非表示
      ui.progress off
      # メニューバーの更新
      @changeMenuTab()
      #TODO: パンくずバーの更新
      ##
      # ビューをフェードイン
      ($ ".ui-#{@current_api}")
        .addClass 'fade'

    index: ->
      ($ 'body').addClass 'index'
      # @fetch_posts 'home'
      @current = 'default'
      ($ ".ui-#{@current}").addClass 'fade'

    search: ->
      # console.log 'search'
      @current = 'default'
      ($ ".ui-#{@current}").addClass 'fade'

    # 記事一覧ページ
    reports: (page) ->
      @fetch_posts 'report', page
    projects: (page) ->
      @fetch_posts 'project', page
    photologs: (page) ->
      @fetch_posts 'photolog', page

    fetch_posts: (post_type, page, done = ->) ->
      unless @fetching
        # クエリをセット
        @current = post_type
        @current_api = if post_type is 'home' then post_type else 'archive'
        media.query.post_type = post_type
        media.query.page = if page then page else 1

        # データ取得
        @beforeFetch()
        $.when($api[@current_api] media.query)
          .done (data) =>
            console.log "API(#{@current_api}) リクエスト結果:", data
            for post in data.posts
              media.archives.add new Archive post
            # タイトルをセット
            media.archivesView.setTitle "#{media.query.post_type}s"
            # 次のページの有無をチェック
            media.query.page++
            media.next = no
            media.next = yes if (data.pages - media.query.page) >= 0
            @afterFetch()
            # 一覧アイテムのフェードイン
            ($ ".ui-#{@current_api} .post-item").not('.fade').each (i) ->
              self = ($ @)
              setTimeout ->
                self.addClass 'fade'
              , i * delaySpeed = 80
              return
            return done null, data
          .fail (err) =>
            ui.progress off
            @fetching = no
            return done err, null

    # 記事単体ページ
    report: (year, month, post_id) ->
      @fetch_post 'report', post_id
    project: (year, month, post_id) ->
      @fetch_post 'project', post_id
    photolog: (year, month, post_id) ->
      @fetch_post 'photolog', post_id

    fetch_post: (post_type, post_id, done = ->) ->
      # console.log "@fetching: ", @fetching
      unless @fetching
        # クエリをセット
        @current = post_type
        @current_api = 'single'
        media.query.post_type = post_type
        media.query.post_id = post_id

        # データ取得
        @beforeFetch()
        $.when($api[@current_api] media.query)
          .done (data) =>
            console.log "API(#{@current_api}) リクエストの結果:", data

            # winheight = $win.height()
            # docheight = $doc.height()
            # ui.popup()
            # console.log winheight, docheight

            # データをもとに画面を描画
            post = _.extend data.post,
              next_url: data.next_url
              previous_url: data.previous_url
            media.singles.add new Single post
            # ajax後の処理
            @afterFetch()
            return done null, data
          .fail (err) =>
            ui.progress off
            @fetching = no
            return done err, null

    loadNext: ->
      # 次のページがある∩XHR中でない∩APIが存在する
      if media.next and not @fetching and @current_api is 'archive' and $api[@current_api]?
        @fetch_posts media.query.post_type, media.query.page
        return

    # pages
    about: ->
      # console.log 'about'
      @current = 'default'
      ($ ".ui-#{@current}").addClass 'fade'
    contact: ->
      # console.log 'contact'
      @current = 'default'
      ($ ".ui-#{@current}").addClass 'fade'
    publications: ->
      # console.log 'publications'
      @current = 'default'
      ($ ".ui-#{@current}").addClass 'fade'

  media =
    archives: new Archives
    singles: new Singles
    layers: new Layers
    archivesView: null
    singlesView: null
    layersView: null
    query:
      post_type: null
      page: 0
      post_id: null
      search: no
      text: null
    next: null
    search:
      focusEnable: yes
    sign_in: $body.hasClass 'signed_in'
    scrolltop: null

  $app = new Application()

  # ===================================
  # Actions
  # ===================================

  $win.on 'resize scroll', (e) ->
    # loadNext
    winheight = $win.height()
    docheight = $doc.height()
    if docheight < window.scrollY + winheight + 600
      $app.loadNext()

    # スクロールアイコンの表示／非表示
    if $doc.scrollTop() > 50
      return if media.scrolltop
      $body.addClass 'scroll'
      media.scrolltop = yes
    else
      return if not media.scrolltop
      $body.removeClass 'scroll'
      media.scrolltop = no

  $doc.on 'click', '.ui-scrollto', ->
    ui.scroll.fast()

  # ===================================
  # Key Actions
  # ===================================

  $doc.on 'keydown', (event) ->
    # console.log "#{String.fromCharCode event.keyCode}(#{event.keyCode}) has pushed"
    switch event.keyCode
      when 83 # s, 検索窓をアンフォーカス
        if ($ ':focus').attr('id') is 's' and ($ '#s').val() is ''
          ($ '#s').blur()
          media.search.focusEnable = no
        return
      when 74 # j
        # ui.moveto yes unless searchfocus
        return
      when 75 # k
        # ui.moveto no unless searchfocus
        return
      when 76 # l
        # ui.liketo()
        return

  $doc.on 'keyup', (event) ->
    switch event.keyCode
      when 83 # s, 検索窓をフォーカス
        if media.search.focusEnable and ($ ':focus').attr('id') isnt 's'
          ($ '#s').focus()
        media.search.focusEnable = yes
        return

  # ===================================
  # 検索窓
  # ===================================

  ($ '#s').on
    'focus': ->
      q = $ '#s'
      q.val '' if q.val() is q.attr 'placeholder'
    'blur': ->
      q = $ '#s'
      q.val q.attr('placeholder') if q.val() is ''
    'click': ->
      q = $ '#s'
      q.focus()


  # ===================================
  # 画像の遅延ロードとローダの表示
  # ===================================

  $.fn.imageload = ->
    @each ->
      $el = $ @
      # 画像タグを作成し、画像の読み込みを開始
      src = $el.data('src')
      $el.find('.preview').css {'background-image': "url(#{src})"}
      $img = ($ 'img').css({'display': 'none'}).attr('src', src)
      # 画像の読み込み完了を取得
      $img.on('load', ->
        $el.parents('.post').addClass 'loaded'
        setTimeout ->
          $img.remove()
          $el.find('.ui-loader').remove()
        , 4000
      ).each ->
        $img.load() if @complete

  ($ '.post .js-load').imageload()


  # ===================================
  # 複数行における省略
  # ===================================

  $.fn.ellipsis = ->
    @each ->
      $el = $ @
      if $el.css('overflow') is 'hidden'
        display = $el.css 'display'
        $el.css 'display', 'block'
        text = $el.html()
        multiline = $el.hasClass 'multiline'
        t = ($ @cloneNode yes)
          .hide()
          .css(
            'display': 'block'
            'position': 'absolute'
            'overflow': 'visible'
          )
          .width( if multiline then $el.width() else 'auto' )
          .height( if multiline then 'auto' else $el.height() )

        $el.after t

        cut_str = ->
          text = text.substr 0, text.length - 1
          t.html text + '…'

        height = ->
          t.height() > $el.height()
        width = ->
          t.width() > $el.width()

        func = if multiline then height else width

        cut_str() while text.length > 0 and func()

        $el.html t.html()
        t.remove()
        $el.css 'display', display

  ($ '.ellipsis').ellipsis()


  # ===================================
  # SFC Google Maps
  # ===================================
  maps_initialize = ->
    latlng = new google.maps.LatLng 35.3876811, 139.4265623
    myOptions =
      zoom: 14
      center: latlng
      mapTypeControlOptions: { mapTypeIds: ['lopan', google.maps.MapTypeId.ROADMAP] },
      disableDefaultUI: no
      scrollwheel: no
    map = new google.maps.Map ($ '#map_canvas')[0], myOptions
    # アイコン設定
    pin = ($ '#map_data').data 'pin-url'
    icon = new google.maps.MarkerImage pin, new google.maps.Size(200, 58), new google.maps.Point(0, 0), new google.maps.Point(80, 58)
    shadow = new google.maps.MarkerImage pin, new google.maps.Size(200, 58), new google.maps.Point(0, 58), new google.maps.Point(80, 58)
    markerOptions =
      position: latlng
      map: map
      icon: icon
      shadow: shadow
      title: "慶應義塾大学湘南藤沢キャンパス 大木研究室"
    marker = new google.maps.Marker markerOptions
    # スタイル付き地図
    styleOptions = []
    ###
    styleOptions = [{ # すべての文字（焦げ茶）
      featureType: "all"
      elementType: "labels"
      stylers: [{ visibility: 'off' }, { hue: '#6d4d38' }]
    }, { # すべての描画（焦げ茶）
      featureType: 'all',
      elementType: 'geometry',
      stylers: [{ visibility: 'off' }, { hue: '#6d4d38' }, { saturation: '-70' }, { gamma: '0.7' }]
    }, { # 市区名
      featureType: 'administrative.locality',
      elementType: 'labels',
      stylers: [{ visibility: 'on' }, { lightness: '20' }]
    }, { # 風景（ベージュ）
      featureType: 'landscape',
      elementType: 'geometry',
      stylers: [{ hue: '#f7f0e4' }, { lightness: '10' }, { saturation: '40' }]
    }, { # ビジネス系の建物（オレンジ）
      featureType: 'poi.business',
      elementType: 'geometry',
      stylers: [{ visibility: 'simplified' }, { hue: '#f98508' }, { lightness: '-20' }, { saturation: '75' }]
    }, { # 公園（黄緑）
      featureType: 'poi.park',
      elementType: 'geometry',
      stylers: [{ visibility: 'simplified' }, { hue: '#99cc00' }, { lightness: '35' }, { saturation: '40' }]
    }, { # すべての道路（黄色）
      featureType: 'road',
      elementType: 'geometry',
      stylers: [{ visibility: 'simplified' }, { hue: '#ffcc22' }, { lightness: '100' }, { saturation: '80' }]
    }, { # 高速道路
      featureType: 'road.highway',
      elementType: 'geometry',
      stylers: [{ lightness: '-30' }]
    }, { # 線路（オレンジ）
      featureType: 'transit.line',
      elementType: 'geometry',
      stylers: [{ visibility: 'on' }, { hue: '#f98508' }]
    }, { # 駅名（焦げ茶）
      featureType: 'transit.station.rail',
      elementType: 'labels',
      stylers: [{ visibility: 'on' }, { hue: '#6d4d38' }, { saturation: '-20' }]
    }, { # 水域（水色）
      featureType: 'water',
      elementType: 'geometry',
      stylers: [{ visibility: 'on' }, { hue: '#b6deea' }, { saturation: '20' }, { lightness: '10' }]
    }]
    ###
    lopanStyledMapOptions = name: "慶應義塾大学湘南藤沢キャンパス 大木研究室"
    lopanType = new google.maps.StyledMapType styleOptions, lopanStyledMapOptions
    map.mapTypes.set "lopan", lopanType
    map.setMapTypeId "lopan"

  maps_initialize() if ($ '#map_canvas')[0]


## Social Plugins ##
# Pocket
not ((d, i) ->
  unless d.getElementById(i)
    j = d.createElement("script")
    j.id = i
    j.src = "https://widgets.getpocket.com/v1/j/btn.js?v=1"
    w = d.getElementById(i)
    d.body.appendChild j
  return
) document, 'pocket-btn-js'

# Facebook Comments & Like Buttons
((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  return  if d.getElementById(id)
  js = d.createElement(s)
  js.id = id
  js.src = '//connect.facebook.net/ja_JP/all.js#xfbml=1&appId=753933521291154'
  fjs.parentNode.insertBefore js, fjs
) document, 'script', 'facebook-jssdk'

# Twitter Tweet Button
###not ((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  unless d.getElementById(id)
    js = d.createElement(s)
    js.id = id
    js.async = yes
    js.src = '//platform.twitter.com/widgets.js'
    fjs.parentNode.insertBefore js, fjs
) document, 'script', 'twitter-wjs' ###
not ((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  p = (if /^http:/.test(d.location) then "http" else "https")
  unless d.getElementById(id)
    js = d.createElement(s)
    js.id = id
    js.async = yes #
    js.src = p + "://platform.twitter.com/widgets.js"
    fjs.parentNode.insertBefore js, fjs
  return
) document, "script", "twitter-wjs"

# Google Analytics
###((i, s, o, g, r, a, m) ->
  i['GoogleAnalyticsObject'] = r
  i[r] = i[r] or ->
    (i[r].q = i[r].q or []).push arguments_
    return
  i[r].l = 1 * new Date()
  a = s.createElement o
  m = s.getElementsByTagName(o)[0]
  a.async = yes
  a.src = g
  m.parentNode.insertBefore a, m
  return
) window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga'
ga 'create', 'UA-41455390-1', 'keio.ac.jp'
ga 'send', 'pageview' ###
root = exports ? @
root._gaq = [
  ['_setAccount', 'UA-41455390-1'],
  ['_setDomainName', 'bosai.sfc.keio.ac.jp'],
  ['_trackPageview']
]
insertGAScript = ->
  ga = document.createElement 'script'
  ga.type = 'text/javascript'
  ga.async = yes
  proto = document.location.protocol
  proto = if (proto is 'https:') then 'https://ssl' else 'http://www'
  ga.src = "#{proto}.google-analytics.com/ga.js"
  s = document.getElementsByTagName 'script'
  s[0].parentNode.insertBefore ga, s
insertGAScript()








