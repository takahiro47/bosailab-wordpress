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
        dataType: 'jsonp'

    single: (data = {}) ->
      return $.ajax "#{$api.domain}/#{data.post_type}/?json=get_post&post_id=#{data.post_id}",
        type: 'GET'
        dataType: 'jsonp'

    page: (data = {}) ->
      return $.ajax "#{$api.domain}/?json=get_page&page_slug=#{data.post_type}",
        type: 'GET'
        dataType: 'jsonp'

  # ===================================
  # UI
  # ===================================

  ui =

    _pl: [
      { p: 'platform', reg: /iphone/i, id: 'iphone' },
      { p: 'platform', reg: /ipod/i, id: 'ipod' },
      { p: 'userAgent', reg: /ipad/i, id: 'ipad' },
      { p: 'userAgent', reg: /blackberry/i, id: 'blackberry' },
      { p: 'userAgent', reg: /android/i, id: 'android' },
      { p: 'platform', reg: /mac/i, id: 'mac' },
      { p: 'platform', reg: /win/i, id: 'windows' },
      { p: 'platform', reg: /linux/i, id: 'linux' }
    ]

    _ua: null

    ua: ->
      return ui._ua  unless ui._ua is null
      return ui._ua = p.id  for p in ui._pl when p.reg.test window.navigator[p.p]

    animationTime: 240

    spinner: (active = no) ->
      if active
        ($ '.ui-spinner').addClass 'ui-spinner-active'
      else
        ($ '.ui-spinner').removeClass 'ui-spinner-active'

    progress: (active = no) ->
      # margin = if media.sign_in then 27 else -4
      # $progress = $ '.ui-progress'
      # if active
      #   $progress.addClass('ui-progress-active').stop().animate
      #     top: 0 + margin
      #   , ui.animationTime
      # else
      #   $progress.stop().animate
      #     top: -1 * $progress.height() + margin
      #   , ui.animationTime, ->
      #     $progress.removeClass 'ui-progress-active'

    scroll:
      swing: (scspeed = 700) ->
        $all.animate scrollTop: 0, scspeed, 'swing'
      fast: ->
        $all.animate scrollTop: 0, 'fast'

    containerWide: (active = no) ->
      $container = $ '.js-container'
      if active
        $container.removeClass('container')
          .addClass 'container-fluid'
      else
        $container.removeClass('container-fluid')
          .addClass 'container'

    pageLoader: (active = no) ->
      $pageLoader = $ '.ui-page-loader'
      if active
        ($ '.ui-article').addClass 'fetching'
        $pageLoader.transition
          opacity: 1
          # y: '0'
          duration: 200
      else
        ($ '.ui-article').removeClass 'fetching'
        $pageLoader.transition
          opacity: 0
          # y: '-200px'
          duration: 200

    # フォトログ用ポップアップウィンドウ
    window: (active = no) ->
      $target = $ '.ui-container'
      if active
        $target.addClass 'behind'
        $target.css 'top': "#{0 - $doc.scrollTop()}px"
      else
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
      if m = uri.match reg
        uris =
          scheme: m[1], authority: m[2], path: m[3]
          query: m[4], fragment: m[5]
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

    # staticMap: (lat, lng, size) ->
    #   base = 'http://maps.googleapis.com/maps/api/staticmap?'
    #   params =
    #     center: "#{lat},#{lng}"
    #     zoom: 13
    #     size: size
    #     markers: "color:brown|label:S|#{lat},#{lng}"
    #     sensor: no
    #   url = base + Object.keys(params).map((key) ->
    #     return "#{encodeURIComponent key}=#{encodeURIComponent params[key]}"
    #   ).join '&'
    #   return url

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
  # Backbone::Contents
  # ===================================

  class Container extends Backbone.Collection

    model: Content

  class ContainerView extends Backbone.View

    el: $ '#container'

    template: _.template ($ '#tmpl-container').html()

    events: {}

    # 最後に追加した投稿タイプ
    ctype: null
    ptype: null

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '#contents').empty()

    append: (content) ->
      @ctype = content.get('content_type') # archive, single, page etc.
      @ptype = content.get('type') # photolog, report, index, about etc.

      view = new ContentView(model: content).render()
      (@$ '#contents').append view.el

      # フェードインのアニメーション
      if @ctype is 'single' and @ptype is 'photolog'
        (@$ '.post-right').transition
          opacity: 1
          y: '0px'
          delay: 400
          duration: 400
          easing: 'ease'
        (@$ '.post-left').transition
          opacity: 1
          x: '0px'
          duration: 600
          easing: 'ease'

      # @setTitle content.get('title')

    updateMenubar: ->
      $menubar0 = $ ".menu-item a[href='/#{media.query.post_type}']"
      $menubar1 = $ ".menu-item a[href='/#{media.query.post_type}/']"
      ($ '.nav-menu').find('.menu-item').removeClass 'current-menu-item'
      $menubar0.parents('.menu-item').addClass 'current-menu-item'
      $menubar1.parents('.menu-item').addClass 'current-menu-item'

    # ページ内のタイトルを変更する
    setTitle: (header_title = null, content_title = null) ->
      console.log header_title, content_title
      # ヘッダ内のタイトル
      if header_title
        ($ 'title').html "#{header_title} | 大木聖子研究室"
      else
        ($ 'title').html "(タイトルなし) | 大木聖子研究室"
      # コンテンツ上のタイトル
      if content_title
        (@$ '.page-title > h1').html content_title
        (@$ '.page-title').css 'height': 'auto'
      else
        (@$ '.page-title > h1').html ''
        (@$ '.page-title').css 'height': '0'


  class Content extends Backbone.Model

    defaults: {}

    initialize: ->

  class ContentView extends Backbone.View

    className: 'content-item'

    template_archive: _.template ($ '#tmpl-archive').html()
    template_single: _.template ($ '#tmpl-single').html()
    template_page: _.template ($ '#tmpl-static').html()
    template_: _.template ($ '#tmpl-content').html()

    events:
      'click': 'navigateToSingle'
      'click .meta-nav-prev': 'navigateToPrevious'
      'click .meta-nav-next': 'navigateToNext'

    initialize: (options) ->
      @template = @["template_#{@model.get('content_type')}"]
      @$el.html @template @model.toJSON()

    render: ->
      self = @
      $self = @$el

      # console.log 'ContentView->render() @model:', @model
      content_type = @model.get 'content_type' # single / archive
      type = @model.get 'type' # photolog / report / project

      # カスタム投稿タイプ
      @$el.addClass "item-#{content_type} item-#{type}"
      # カスタム投稿フィールド
      acf = @model.get 'acf'
      # data属性
      @$el.attr 'data-id', @model.get('id')
      @$el.attr 'data-href', @model.get('url')
      # 日付アイコン
      date = ui.parse_date @model.get('date')
      (@$ '.date-month').text date.month
      (@$ '.date-day').text date.day
      (@$ '.date-year').text date.year

      if content_type is 'archive'
        # フォトログ
        if type is 'photolog'
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
        else if type is 'report'
          @$el.addClass 'col-sm-8 col-sm-offset-4 col-xs-12'
          # 抜粋文
          if excerpt = @model.get('excerpt')
            (@$ '.excerpt').text excerpt.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

        # プロジェクト
        else if type is 'project'
          @$el.addClass 'loaded col-sm-4 col-xs-12'
          # サムネイル
          thumbnail = @model.get('thumbnail_images')
          if thumbnail.medium
            (@$ '.post-preview').css
              'background-image': "url('#{thumbnail.medium.url}')"

      else if content_type is 'single'
        # タグ
        tags = @model.get('tags')
        for tag in tags
          $tag = ($ '<div />').addClass('tag').text tag.title
          (@$ '.ui-tags').append $tag

        # フォトログ
        if type is 'photolog'
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
          # アニメーション用のずれ
          (@$ '.post-right').transition
            opacity: 0
            y: '-30px'
            duration: 0
          (@$ '.post-left').transition
            opacity: 0
            x: '90px'
            duration: 0

        # 活動レポート
        else if type is 'report'
          @$el.addClass 'loaded col-sm-8 col-sm-offset-4 col-xs-12'

        # プロジェクト
        else if type is 'project'
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

      else if content_type is 'page'
        # About
        if slug = @model.get('slug') is 'about'
          # メンバー一覧を描画
          console.log acf = @model.get 'acf'

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

    # in Archive
    navigateToSingle: ->
      if @model.get('content_type') is 'archive'
        url = ui.parse_uri(@$el.data('href')).path
        $app.navigate url, yes

    # in Single
    navigateToPrevious: (event) ->
      event.preventDefault()
      (@$ '.post-right').transition
        opacity: 0
        y: '-30px'
        duration: 400
        easing: 'ease'
      (@$ '.post-left').transition
        opacity: 0
        x: '-90px'
        delay: 400
        duration: 600
        easing: 'ease'
      url = ui.parse_uri(@model.get('previous_url')).path
      setTimeout ->
        $app.navigate url, yes
      , 800
    navigateToNext: (event) ->
      event.preventDefault()
      (@$ '.post-right').transition
        opacity: 0
        y: '-30px'
        duration: 400
        easing: 'ease'
      (@$ '.post-left').transition
        opacity: 0
        x: '90px'
        delay: 400
        duration: 600
        easing: 'ease'
      url = ui.parse_uri(@model.get('next_url')).path
      setTimeout ->
        $app.navigate url, yes
      , 800

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
      '(/)': 'index'
      '(/)?s=(:text)': 'search'

      'project(/)': 'projects'
      'project/page/:page(/)': 'projects'
      'project/:year/:month/:post_id(/)': 'project'

      'report(/)': 'reports'
      'report/page/:page(/)': 'reports'
      'report/:year/:month/:post_id(/)': 'report'

      'photolog(/)': 'photologs'
      'photolog/page/:page(/)': 'photologs'
      'photolog/:year/:month/:post_id(/)': 'photolog'

      'about(/)': 'about'
      'contact(/)': 'contact'
      'publications(/)': 'publications'

    initialize: ->
      @navigate location.pathname, yes
      Backbone.history.start pushState: on
      $ =>
        media.containerView = new ContainerView media.container
        @$title = $ 'title'

    # Page
    index: (text='') ->
      console.log 'index', text
      q =
        api: 'page'
        post_type: 'home'
      @fetch q
    search: ->
      q =
        api: 'page'
        post_type: 'search'
      @fetch q
    about: ->
      q =
        api: 'page'
        post_type: 'about'
      @fetch q
    contact: ->
      q =
        api: 'page'
        post_type: 'contact'
      @fetch q
    publications: ->
      q =
        api: 'page'
        post_type: 'publications'
      @fetch q
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
        console.log "Page: #{media.query.page}, Query: ", query
        if media.query.page is null or media.query.page is undefined
          # ページ数を指定して読み込んだ場合以外は, ページ数が未設定なので1にセット
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
        ui.pageLoader on

        # 2ページ目以降の読み込み or ポップアップ "以外"では上部にスクロール
        unless (media.query.page > 1) or no # p2以降 or ポップアップ(今は常に非強制) を除く
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
            media.prequery = media.query

            # 次ページの有無を確認
            media.next = no
            media.next = yes if (data.pages - media.query.page) > 0

            ## 読み込み後の画面を準備
            ## -------------------------------------

            # ローディング状態を解除
            @fetching = no
            ui.progress off
            ui.pageLoader off

            # TODO パンくずバーの更新
            # ui.breadcrumbs hoge

            # メニューバーを更新
            media.containerView.updateMenubar()

            # スタイルシートの切り替えと、アイテムのリセット制御
            pre_ctype = media.containerView.ctype
            pre_ptype = media.containerView.ptype
            ctype = media.query.api
            ptype = media.query.post_type
            # console.log "#{pre_ctype}.#{pre_ptype} => #{ctype}.#{ptype}"

            # スタイルシートの切り替え
            ($ '#contents')
              .removeClass('archive single page')
              .removeClass('project report photolog')
              .removeClass('index about publications contact')
              .addClass "#{ctype} #{ptype}"

            # 取得した投稿アイテムをBackboneのモデルに追加
            if media.query.api is 'archive'
              # タイトルをセット
              media.containerView.setTitle "#{media.query.post_type}s", "#{media.query.post_type}s"
              # アイテムのリセット
              if pre_ctype isnt 'archive' or                     # シングル => アーカイブ
                (ctype is 'archive' and ptype isnt pre_ptype) # アーカイブ => その他のアーカイブ
                  media.container.reset()
              # コンテナの幅を通常に
              ui.containerWide off
              # アイテムの追加
              for post in data.posts
                post = _.extend post,
                  content_type: 'archive'
                media.container.add new Content post

            else if media.query.api is 'single'
              # タイトルをセット
              media.containerView.setTitle data.post?.title_plain?, "#{media.query.post_type}s"
              , no
              # アイテムのリセット
              media.container.reset()
              # コンテナの幅を通常に
              ui.containerWide off
              # アイテムの追加
              post = _.extend data.post,
                content_type: 'single'
                next_url: data.next_url
                previous_url: data.previous_url
              media.container.add new Content post

            else if media.query.api is 'page' # 固定ページ
              # タイトルをセット
              media.containerView.setTitle data.page?.title_plain?, null
              # アイテムのリセット
              media.container.reset()
              # コンテナの幅を調整
              if media.query.post_type is 'about'
                ui.containerWide on
              else
                ui.containerWide off
              # アイテムの追加
              post = _.extend data.page,
                content_type: 'page'
              media.container.add new Content post
              # アイテム描画後に必要な処理
              if media.query.post_type is 'about'
                # 動きをセット
                wow = new WOW
                  boxClass: 'animate'
                  offset: 0
                  mobile: no
                wow.init()
                ui.gmap ($ '#map_canvas'), 35.3876811, 139.4265623, 14, "慶應義塾大学湘南藤沢キャンパス 大木研究室"

            ## イベントをreturn
            ## -------------------------------------
            return done null, data

          .fail (err) =>
            console.log err
            ui.progress off
            ui.pageLoader off
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
    container: new Container
    containerView: null
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
  # Links
  # ===================================

  # タイトルロゴ
  ($ '.js-navi-home').on
    'click': (event) ->
      event.preventDefault()
      $target = $ event.currentTarget
      $app.navigate '/', yes

  # ナビバーのリンクをフック
  ($ '#menu-header a').on
    'click': (event) ->
      event.preventDefault()
      $target = $ event.currentTarget
      console.log url = ui.parse_uri($target.attr 'href').path
      $app.navigate url, yes

  # TODO パンくずナビ


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
        # if ($ ':focus').attr('id') is 's' and ($ '#s').val() is ''
        #   ($ '#s').blur()
        #   media.search.focusEnable = no
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
        # if media.search.focusEnable and ($ ':focus').attr('id') isnt 's'
        #   ($ '#s').focus()
        # media.search.focusEnable = yes
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
