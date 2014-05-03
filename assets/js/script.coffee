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
  # Tests
  # ===================================
  # ($ '#wpadminbar').remove()
  # $body.removeClass 'signed_in'

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
      console.log ''

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
      date = new Date datetime.replace /-/g, '/'
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

    gmap: ($el, lat, lng, zoom=13, title='') ->
      zoom = 13 if zoom is 0
      latlng = new google.maps.LatLng lat, lng
      myOptions =
        zoom: zoom
        center: latlng
        disableDefaultUI: no
        scrollwheel: no
      map = new google.maps.Map $el[0], myOptions
      markerOptions =
        position: latlng
        map: map
        title: title
      marker = new google.maps.Marker markerOptions

    gmap_sfc: ($el) ->
      @gmap $el, 35.3876811, 139.4265623, 13, "慶應義塾大学湘南藤沢キャンパス 大木研究室"

    staticMap: (lat, lng, size) ->
      base = 'http://maps.googleapis.com/maps/api/staticmap?'
      params =
        center: "#{lat},#{lng}"
        zoom: 13
        size: size
        markers: "color:brown|label:S|#{lat},#{lng}"
        sensor: no
      url = base + Object.keys(params).map((key) ->
        return "#{encodeURIComponent key}=#{encodeURIComponent params[key]}"
      ).join '&'
      return url

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
      self = @
      $self = @$el
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
        @$el.addClass 'col-xs-6 col-sm-3'
        # サムネイル
        if acf.photo
          (@$ '.post-preview').css
            'background-image': "url('#{acf.photo.sizes.medium}')"
          image = new Image()
          image.onload = ->
            $self.addClass 'loaded'
          image.src = acf.photo.sizes.medium
        # 抜粋文
        if acf.body
          (@$ '.excerpt').text acf.body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

      # 活動レポート
      if @model.get('type') is 'report'
        @$el.addClass 'col-sm-8 col-sm-offset-4 col-xs-12'
        # 抜粋文
        if excerpt = @model.get('excerpt')
          (@$ '.excerpt').text excerpt.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

      # プロジェクト
      if @model.get('type') is 'project'
        @$el.addClass 'loaded col-sm-4 col-xs-12'
        # サムネイル
        thumbnail = @model.get('thumbnail_images')
        if thumbnail.medium
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
      $self = @$el
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
        @$el.addClass 'col-xs-12'
        # サムネイル
        if acf.photo
          (@$ '.post-preview').css
            'background-image': "url(\"#{acf.photo.url}\")"
          image = new Image()
          image.onload = ->
            $self.addClass 'loaded'
          image.src = acf.photo.url
        # Google Maps
        ui.gmap (@$ '.post-maps'), acf.position.lat, acf.position.lng, 12, ''

      # 活動レポート
      if @model.get('type') is 'report'
        @$el.addClass 'loaded col-sm-8 col-sm-offset-4 col-xs-12'

      # プロジェクト
      if @model.get('type') is 'project'
        @$el.addClass 'loaded col-xs-12'
        # サムネイル
        if thumbnail = @model.get('thumbnail_images')
          if thumbnail.large
            (@$ '.post-preview').css
              'background-image': "url('#{thumbnail.large.url}')"
          else if thumbnail.medium
            (@$ '.post-preview').css
              'background-image': "url('#{thumbnail.medium.url}')"


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
      @setTitle content.get('title')

    setTitle: (title) ->
      if title
        ($ 'title').html "#{title} | 大木聖子研究室"
        # (@$ 'hgroup.page-title > h1').html title
        # (@$ 'hgroup.page-title').css 'height': 'auto'
      else
        ($ 'title').html "(タイトルなし) | 大木聖子研究室"
        # (@$ 'hgroup.page-title > h1').html ''
        # (@$ 'hgroup.page-title').css 'height': '0'
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

    # Page
    index: ->
      ($ 'body').addClass 'index'
      ($ ".ui-default").addClass 'fade'
    search: ->
      ($ ".ui-default").addClass 'fade'
    about: ->
      ($ ".ui-default").addClass 'fade'
      ui.gmap ($ '#map_canvas'), 35.3876811, 139.4265623, 14, "慶應義塾大学湘南藤沢キャンパス 大木研究室"
    contact: ->
      ($ ".ui-default").addClass 'fade'
    publications: ->
      ($ ".ui-default").addClass 'fade'
    # Article
    reports: (page) ->
      q =
        api: 'archive'
        post_type: 'report'
        page: page
      @fetch q
    projects: (page) ->
      q =
        api: 'archive'
        post_type: 'project'
        page: page
      @fetch q
    photologs: (page) ->
      q =
        api: 'archive'
        post_type: 'photolog'
        page: page
      @fetch q
    # Single
    report: (year, month, post_id) ->
      q =
        api: 'single'
        post_type: 'report'
        post_id: post_id
      @fetch q
    project: (year, month, post_id) ->
      q =
        api: 'single'
        post_type: 'project'
        post_id: post_id
      @fetch q
    photolog: (year, month, post_id) ->
      q =
        api: 'single'
        post_type: 'photolog'
        post_id: post_id
      @fetch q

    fetch: (query = {}, done = ->) ->
      unless @fetching
        ## 読み込みの為の変数準備
        ## -------------------------------------
        # 引数からクエリをセット
        media.query = {}
        media.query = query
        # 次に読み込むページ数などを整理
        console.log 'page: ', media.query.page
        if media.query.page is null # (ページ数を指定して読み込んだ場合は除く)
          # 2ページ目以降の読み込みだった場合は, ページ数が未設定なので1にセット
          # => ポストタイプが前回のfetchと異なる場合
          if media.prequery.post_type isnt media.query.post_type
            media.query.page = 1
        # デバッグ出力
        console.log "API(#{media.query.api}) リクエスト準備:", media

        ## 読み込む前の画面を準備
        ## -------------------------------------
        # ローディング状態にする
        @fetching = yes
        ui.progress on
        # すべてのビューをいったんフェードアウト
        ($ '.ui-article > *').not(".ui-#{media.query.api}").removeClass 'fade'
        # TODO: 画面中央にローディングアイコンを表示

        # 2ページ目以降の読み込み or ポップアップ "以外"では上部にスクロール
        unless (media.query.page > 1) or no # p2以降 or ポップアップ(今は常にfalse) を除く
          ui.scroll.swing()

        ## AJAXリクエストを実行
        ## -------------------------------------
        $.when($api[media.query.api] media.query)
          .done (data) =>
            ## 読み込み後の変数を調整
            ## -------------------------------------
            # デバッグ出力
            console.log "API(#{media.query.api}) リクエスト結果:", data
            # 実行したクエリをクローン
            media.prequery = {}
            media.prequery = media.query
            # 次ページの有無を確認
            media.next = no
            media.next = yes if (data.pages - media.query.page) > 0

            ## 読み込み後の画面を準備
            ## -------------------------------------
            # ローディング状態を解除
            @fetching = no
            ui.progress off
            # h1にタイトルをセット
            if media.query.api is 'archive'
              media.archivesView.setTitle "#{media.query.post_type}s"
            else if media.query.api is 'single'
              media.singlesView.setTitle()
            # TODO: headにタイトルをセット

            # TODO: パンくずバーの更新

            # メニューバーを更新
            $menubar = ($ "li.menu-item > a[href='/#{media.query.post_type}']")
            $menubar.parents('.nav-menu').find('.menu-item').removeClass 'current-menu-item'
            $menubar.parents('.menu-item').addClass 'current-menu-item'
            # ビューをフェードイン
            ($ ".ui-#{media.query.api}").addClass 'fade'
            # 取得した投稿アイテムをBackboneのモデルに追加
            if media.query.api is 'archive'
              for post in data.posts
                media.archives.add new Archive post
            else if media.query.api is 'single'
              post = _.extend data.post,
                next_url: data.next_url
                previous_url: data.previous_url
              media.singles.add new Single post
            # 取得した投稿アイテムのフェードイン(Archiveのみ)
            if media.query.api is 'archive'
              ($ ".ui-#{media.query.api} .post-item").not('.fade').each (i) ->
                self = ($ @)
                setTimeout ->
                  self.addClass 'fade'
                , i * delaySpeed = 80
                return

            ## イベントをreturn
            ## -------------------------------------
            return done null, data

          .fail (err) =>
            ui.progress off
            @fetching = no
            return done err, null

    loadNext: ->
      unless @fetching
        # 次のページがあり、かつAPIが存在する場合はフェッチを実行
        if media.next and $api[media.query.api]?
          q = media.query
          q.page++
          @fetch q


  media =
    archives: new Archives
    singles: new Singles
    layers: new Layers
    archivesView: null
    singlesView: null
    layersView: null
    query:
      api: 'default'
      post_type: null
      page: 1
      post_id: null
      search: no
      text: null
    prequery: {}
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
  # Footer Google Maps
  # ===================================
  ui.gmap_sfc ($ '#map_canvas_footer')


# ===================================
# Social Plugins
# ===================================

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
