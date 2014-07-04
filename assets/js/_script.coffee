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

    imageload: ->
      console.log 'run'
      $photograph = $ '.archive-media--photograph'
      if uri = ui.sample_url($photograph.css 'background-image')
        image = new Image()
        image.onload = ->
          ($ '.archive-media--photograph-wrap').addClass 'loaded'
        image.src = uri
      return

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

    # URLの抽出
    sample_url: (text) ->
      text.match /https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:@&=+$,%#]+[a-z]/g

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

    parse_pixel: (pixel) ->
      num = String(pixel).replace 'px', ''
      num = parseInt ~~(parseFloat num)
      if not num or num is 0 then num = 1
      return num

    gmap: ($el, lat=35.3876811, lng=139.4265623, zoom=13, title='慶應義塾大学湘南藤沢キャンパス 大木研究室') ->
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

    # in  : 2014-04-21 21:18:12
    getRelativeTime: (entryDate='2000-01-01 00:00:00') ->
      currentDate = new Date()
      time = entryDate.match /^([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+):([0-9]+)$/
      entryDate = new Date(time[1], time[2] - 1, time[3], time[4], time[5], time[6])
      elapsedTime = (currentDate.getTime() - entryDate.getTime()) / 1000
      elapsedTime = Math.ceil(elapsedTime) # 小数点以下切り上げ
      message = null
      if elapsedTime < 60 #  1 分未満
        message = "たった今"
      else if elapsedTime < 120 #  2 分未満
        message = "約 1分前"
      else if elapsedTime < (60 * 60) #  1 時間未満
        message = "約" + Math.floor(elapsedTime / 60) + "分前"
      else if elapsedTime < (120 * 60) #  2 時間未満
        message = "約 1時間前"
      else if elapsedTime < (24 * 60 * 60) #  1 日未満
        message = "約" + Math.floor(elapsedTime / 3600) + "時間前"
      else if elapsedTime < (7 * 24 * 60 * 60) # 1 週間未満
        message = "約" + Math.floor(elapsedTime / 86400) + "日前"
      else # 1 週間以上
        message = "約" + Math.floor(elapsedTime / 604800) + "週間前"
      return message

    # ===================================
    # ローディング
    # ===================================

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

    # ===================================
    # パンくずナビの生成
    # ===================================

    createBreadCrumbs: (q = {}, post = {}) ->
      $breadcrumb = $ '.js-breadcrumbs'
      $nav = ($ '<nav />')
        .addClass('ui-breadcrumbs')
        .attr 'xmlns:v', 'http://rdf.data-vocabulary.org/#'
      # ホームのナビ
      $nav.append(
        ($ '<a />').attr(
          'href': '/'
          'rel': 'v:url'
          'property', 'v:title'
        ).append(
          ($ '<i />').addClass 'fa fa-home home'
        )
      ).append(
        ($ '<i />').addClass 'fa fa-angle-right arrow'
      )
      # 以降のナビ
      $arrow = ($ '<i />').addClass 'fa fa-angle-right arrow'
      if q.api is 'archive' # 投稿タイプのみ(Archive)
        $nav.append(
          ($ '<span />').html "#{q.post_type}s"
        )
      else if post.ctype is 'single' # 投稿タイプ + 単体記事(Single)
        $nav.append(
          ($ '<a />').attr('href', "/#{post.ptype}").append(
            ($ '<span />').html post.ptype
          )
        ).append($arrow).append(
          ($ '<span />').addClass('current').html post.title_plain
        )
      else if post.ctype is 'page' # ページ
        unless "#{post.post_type}" is 'home'
          $nav.append(
            ($ '<span />').html post.title_plain
          )
      # 生成した<nav />でパンくずを上書き更新
      $breadcrumb.html $nav

    # ===================================
    # モバイル版におけるメニューの開閉トグル
    # ===================================

    toggleMobileMenu: (active = no) ->
      $toggleTarget = $ '.ui-navi-menu'
      if active
        ui.toggleMobileSearch no
        $toggleTarget.addClass 'visible'
      else
        $toggleTarget.removeClass 'visible'

    toggleMobileSearch: (active = no) ->
      $toggleTarget = $ '.ui-navi-search'
      if active
        ui.toggleMobileMenu no
        ($ '#s').focus()
        $toggleTarget.addClass 'visible'
      else
        $toggleTarget.removeClass 'visible'

  ($ '.js-toggle-menu').on
    'click': (e) ->
      $toggleTarget = $ '.ui-navi-menu'
      if $toggleTarget.hasClass 'visible'
        ui.toggleMobileMenu no
      else
        ui.toggleMobileMenu yes

  ($ '.js-toggle-search').on
    'click': (e) ->
      $toggleTarget = $ '.ui-navi-search'
      if $toggleTarget.hasClass 'visible'
        ui.toggleMobileSearch no
      else
        ui.toggleMobileSearch yes


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
  # Backbone::ContactBox
  # ===================================

  class ContactBox extends Backbone.Collection

    model: Contact

  class ContactBoxView extends Backbone.View

    el: $ '#contactBox'

    template: _.template ($ '#tmpl-contactbox').html()

    events:
      'click .gallery-layer__close': 'close'
      'click .gallery-layer__close-target--large': 'close'
      'click .gallery-layer__close-target--small': 'close'
      'click .gallery-content__info__close': 'close'
      'click .contact-content__close': 'close'

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      (@$ '.gallery-layer__content').addClass 'gallery-layer__content--contact'
      return @

    clear: ->
      (@$ '.gallery-layer__media').empty()

    append: (content) ->
      @open()
      view = new ContactView(model: content).render()
      (@$ '.gallery-layer__media').append view.el

    open: ->
      (@$ '.gallery-layer').addClass 'active'
      $body.addClass 'gallery-enabled'

    close: ->
      # ギャラリービューを非表示
      (@$ '.gallery-layer').removeClass 'active'
      $body.removeClass 'gallery-enabled'
      media.contactMode = off
      # ギャラリーをリセット
      @collection.reset() # @clear()
      # 画面遷移
      window.history.back()

  class Contact extends Backbone.Model

    initialize: ->

  class ContactView extends Backbone.View

    class: 'gallery-content'

    template: _.template ($ '#tmpl-contact').html()

    events: {}

    initialize: (options) ->
      @$el.html @template @model.toJSON()

    render: ->
      return @

  # ===================================
  # Backbone::GalleryBox
  # ===================================

  class GalleryBox extends Backbone.Collection

    model: Gallery

  class GalleryBoxView extends Backbone.View

    el: $ '#galleryBox'

    template: _.template ($ '#tmpl-gallerybox').html()

    events:
      'click .gallery-layer__close': 'close_direct'
      'click .gallery-layer__close-target--large': 'close_direct'
      'click .gallery-layer__close-target--small': 'close_direct'
      'click .gallery-content__info__close': 'close_direct'

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add',   @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '.gallery-layer__media').empty()

    append: (content) ->
      @open()
      view = new GalleryView(model: content).render()
      (@$ '.gallery-layer__media').append view.el

      # 幅を自動調整
      @fitGallery()

    open: ->
      (@$ '.gallery-layer').addClass 'active'
      $body.addClass 'gallery-enabled'

    close_direct: ->
      @close()
      # 画面遷移
      $app.navigate '/photolog/', no
      # フォトログアーカイブの状態に戻す
      media.next = yes
      media.query.api = 'archive'
      media.query.post_type = 'photolog'
      # タイトルとメニューバーの変更
      media.containerView.updateMenubar()
      media.containerView.setTitle 'フォトログ', 'フォトログ'

    close: ->
      # ギャラリービューを非表示
      (@$ '.gallery-layer').removeClass 'active'
      $body.removeClass 'gallery-enabled'
      media.galleryMode = off
      # ギャラリーをリセット
      @collection.reset() # @clear()

    # ギャラリーのリサイズ
    # (画面幅 - 左右のパディング - 情報バー) * 写真標準のアスペクト比
    fitGallery: ->
      winheight = $win.height()
      winwidth = $win.width()

      height = (winwidth - 32*2) * (2 / 3) * (540 / 720)
      height = 540 if height > 540
      margin = (540 - height) / 2
      if (1080 + 32*2) < winwidth
        (@$ '.gallery-layer__media--single').css 'height': '540px'
        (@$ '.gallery-layer__content').css 'margin': '0 auto'
      else if 940 < winwidth
        (@$ '.gallery-layer__media--single').css 'height': "#{height}px"
        (@$ '.gallery-layer__content').css 'margin': "#{margin}px auto"
      else # if winwidth < 940
        (@$ '.gallery-layer__media--single').css 'height': 'auto'
        (@$ '.gallery-layer__content').css 'margin': '0 auto'
      return

  # ===================================
  # Backbone::Gallery
  # ===================================

  class Gallery extends Backbone.Model

    initialize: ->

  class GalleryView extends Backbone.View

    class: 'gallery-content loaded'

    template: _.template ($ '#tmpl-gallery').html()

    events:
      'click .gallery-navigation--prev': 'navigateToNext'
      'click .gallery-navigation--next': 'navigateToPrevious'

    initialize: (options) ->
      @$el.html @template @model.toJSON()

    render: ->
      self = @
      $self = @$el

      # 幅を可変に
      @$el.addClass 'gallery-layer__media--single'

      # 高さを指定
      @$el.css 'height', '540px'

      # カスタム投稿フィールド
      acf = @model.get 'acf'
      # data属性
      @$el.attr 'data-id', @model.get('id')
      # 日付アイコン
      date = ui.parse_date @model.get('date')
      (@$ '.date-month').text date.month
      (@$ '.date-day').text date.day
      (@$ '.date-year').text date.year
      # 相対時刻
      relative_time = ui.getRelativeTime(@model.get 'date')
      (@$ '.gallery-content__relative-time').text relative_time

      # フォト
      if acf.photo
        (@$ '.post-preview').css 'background-image': "url(\"#{acf.photo.url}\")"
        image = new Image()
        image.onload = ->
          $self.addClass 'loaded'
        image.src = acf.photo.url
      # タグ
      tags = @model.get 'tags'
      for tag in tags
        $tag = ($ '<div />').addClass('tag').text tag.title
        (@$ '.ui-tags').append $tag
      # 抜粋文
      if acf.body
        (@$ '.excerpt').text acf.body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

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

    navigateToPrevious: (event) ->
      event.preventDefault()
      url = ui.parse_uri(@model.get 'previous_url').path
      $app.navigate url, yes

    navigateToNext: (event) ->
      event.preventDefault()
      url = ui.parse_uri(@model.get 'next_url').path
      $app.navigate url, yes


  # ===================================
  # Backbone::Container
  # ===================================

  class Container extends Backbone.Collection

    model: Content

  class ContainerView extends Backbone.View

    el: $ '#container'

    template: _.template ($ '#tmpl-container').html()

    events: {}

    initialize: (@collection) ->
      @$el.html @template()
      @listenTo @collection, 'reset', @clear
      @listenTo @collection, 'add', @append
      @render()

    render: ->
      return @

    clear: ->
      (@$ '#contents--gallery').empty() # single.photolog
      (@$ '#contents--page').empty()
      if media.masonryMode
        #(@$ '#contents--page').masonry 'destroy'
        media.masonryMode = off

    append: (content) ->
      # Reset CSS
      $layer = @$ '.page-layer__content'
      $layer.removeClass 'page-layer__content--archive page-layer__content--report page-layer__content--full'

      # Add Custom CSS
      switch "#{content.get 'ctype'}.#{content.get 'ptype'}"
        when 'archive.photolog', 'archive.project'
          $layer.addClass 'page-layer__content--archive'
        when 'archive.report', 'single.report'
          $layer.addClass 'page-layer__content--report'
        when 'page.about'
          $layer.addClass 'page-layer__content--full'

      # Add model
      view = new ContentView(model: content).render()
      switch "#{content.get 'ctype'}.#{content.get 'ptype'}"
        # when 'archive.photolog'
        #   (@$ '#contents--page').append(view.el).masonry 'appended', view.el
        when 'single.photolog'
          (@$ '.page-layer__vertical-center').addClass 'hidden'
          (@$ '.gallery-layer__vertical-center').removeClass 'hidden'
          # Add model view
          (@$ '#contents--gallery').append view.el
          # 幅を自動調整
          @fitGallery()
        else
          (@$ '.page-layer__vertical-center').removeClass 'hidden'
          (@$ '.gallery-layer__vertical-center').addClass 'hidden'
          # Add model view
          (@$ '#contents--page').append view.el

      # After model added
      switch "#{content.get 'ctype'}.#{content.get 'ptype'}"

        # when 'single.photolog'

        #   # Fade-in Animations
        #   (@$ '.gallery-layer__vertical-center').transition
        #     opacity: 1
        #     y: '0px'
        #     delay: 400
        #     duration: 400
        #     easing: 'ease'

        when 'page.home'

          $.when($api['archive'] {'post_type': 'project',  'page': 1})
            .done (data) =>

              # for project in data.posts
              #   project = _.extend project,
              #     'ctype': 'archive'
              #     'ptype': 'project'
              #   console.log view = new ContentView(model: project).render()

              return

            .fail (err) =>
              console.log err
              return

      # 抜粋文の短縮
      (@$ '.ellipsis').ellipsis()

    initMasonry: ->
      #(@$ '#contents--page').masonry
      #  itemSelector: '.item-photolog'
      #  columnWidth: 194 #234
      #  isFitWidth: on
      media.masonryMode = on

    # ギャラリーのリサイズ
    # (画面幅 - 左右のパディング - 情報バー) * 写真標準のアスペクト比
    fitGallery: ->
      winheight = $win.height()
      winwidth = $win.width()

      height = (winwidth - 32*2) * (2 / 3) * (540 / 720)
      height = 540 if height > 540
      margin = (540 - height) / 2
      if (1080 + 32*2) < winwidth
        (@$ '.gallery-layer__media--single').css 'height': '540px'
        (@$ '.gallery-layer__content').css 'margin': '0 auto'
      else if 940 < winwidth
        (@$ '.gallery-layer__media--single').css 'height': "#{height}px"
        (@$ '.gallery-layer__content').css 'margin': "#{margin}px auto"
      else # if winwidth < 940
        (@$ '.gallery-layer__media--single').css 'height': 'auto'
        (@$ '.gallery-layer__content').css 'margin': '0 auto'
      return

    updateMenubar: ->
      $menubar0 = $ ".menu-item a[href='/#{media.query.post_type}']"
      $menubar1 = $ ".menu-item a[href='/#{media.query.post_type}/']"
      ($ '.navigation-menu').find('.menu-item').removeClass 'current-menu-item'
      $menubar0.parents('.menu-item').addClass 'current-menu-item'
      $menubar1.parents('.menu-item').addClass 'current-menu-item'

    # ページ内のタイトルを変更する
    setTitle: (header_title = null, content_title = null) ->
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


  # ===================================
  # Backbone::Content
  # ===================================

  class Content extends Backbone.Model

    defaults: {}

    initialize: ->

  class ContentView extends Backbone.View

    template_archive: _.template ($ '#tmpl-archive').html()
    template_single: _.template ($ '#tmpl-single').html()
    template_page: _.template ($ '#tmpl-static').html()
    template_: _.template ($ '#tmpl-content').html()

    events:
      'click .js-navi-single': 'navigateToSingle'
      'click .js-navi-prev': 'navigateToPrevious'
      'click .js-navi-next': 'navigateToNext'
      'click .meta-nav-prev': 'navigateToPrevious'
      'click .meta-nav-next': 'navigateToNext'

    initialize: (options) ->
      console.log @model
      @template = @["template_#{@model.get('ctype')}"]
      console.log @template
      @$el.html @template @model.toJSON()
      console.log @$el

    render: ->
      self = @
      $self = @$el

      ctype = @model.get 'ctype' # single / archive
      ptype = @model.get 'ptype' # photolog / report / project
      # slug  = @model.get 'slug'  # home / about / contact / publications

      # CSS class
      @$el.addClass "page-layer__media--#{ptype}--#{ctype}"

      # Data attributes
      @$el.attr 'data-id', @model.get('id')

      # Calendar icon
      date = ui.parse_date @model.get('date')
      (@$ '.date-month').text date.month
      (@$ '.date-day').text date.day
      (@$ '.date-year').text date.year

      # Tags
      tags = @model.get 'tags'
      if tags
        for tag in tags
          $tag = ($ '<div />').addClass('tag').text tag.title
          (@$ '.ui-tags').append $tag

      # Custom Post Fields
      acf = @model.get 'acf'

      switch "#{ctype}.#{ptype}"
        # フォトログ
        when 'archive.photolog'
          # サムネイル
          if acf.photo
            (@$ '.archive-media--photograph').css 'background-image': "url('#{acf.photo.sizes.medium}')"
            image = new Image()
            image.onload = ->
              ($ '.archive-media--photograph-wrap').addClass 'loaded'
            image.src = acf.photo.sizes.medium

          # # 抜粋文
          # if acf.body
          #   excerpt = acf.body
          #   (@$ '.excerpt').text excerpt.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

          # 日付
          (@$ '.archive-media--photolog__date').text "#{date.month} #{date.year}"

        # 活動レポート
        when 'archive.report'

          # サムネイル
          if photo = @model.get 'thumbnail_images'
            (@$ '.archive-media--photograph').css 'background-image': "url('#{photo.medium.url}')"
            image = new Image()
            image.onload = ->
              ($ '.archive-media--photograph-wrap').addClass 'loaded'
            image.src = photo.medium.url

          # 抜粋文
          if excerpt = @model.get 'excerpt'
            (@$ '.archive-media--report__excerpt').text excerpt.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

          # 相対時刻
          relative_time = ui.getRelativeTime(@model.get 'date')
          (@$ '.archive-media--report__relative-date').text relative_time

        # プロジェクト
        when 'archive.project'

          @$el.addClass 'col-sm-4'

          # サムネイル
          if photo = @model.get 'thumbnail_images'
            (@$ '.archive-media--photograph').css 'background-image': "url('#{photo.medium.url}')"
            image = new Image()
            image.onload = ->
              ($ '.archive-media--photograph-wrap').addClass 'loaded'
            image.src = photo.medium.url

        # フォトログ
        when 'single.photolog'

          # 幅を可変に
          @$el.addClass 'gallery-layer__media--single'

          # 高さを指定
          @$el.css 'height', '540px'

          # 相対時刻
          relative_time = ui.getRelativeTime(@model.get 'date')
          (@$ '.gallery-content__relative-time').text relative_time

          # フォト
          if photo = acf.photo
            (@$ '.post-preview').css 'background-image': "url(\"#{photo.url}\")"
            image = new Image()
            image.onload = ->
              $self.addClass 'loaded'
            image.src = photo.url

          # 抜粋文
          if acf.body
            (@$ '.excerpt').text acf.body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, '')

          # Google Maps
          # ui.gmap (@$ '.post-maps'), acf.position.lat, acf.position.lng, 12, ''

          # アニメーション用のずれ
          # (@$ '.gallery-layer__vertical-center').transition
          #   opacity: 0
          #   y: '-30px'
          #   duration: 0

        # 活動レポート
        when 'single.report'

          # 相対時刻
          relative_time = ui.getRelativeTime(@model.get 'date')
          (@$ '.archive-media--report__relative-date').text relative_time

        # プロジェクト
        when 'single.project'

          # サムネイル
          if thumbnail = @model.get 'thumbnail_images'
            if thumbnail.large
              (@$ '.post-preview').css 'background-image': "url('#{thumbnail.large.url}')"
            else if thumbnail.medium
              (@$ '.post-preview').css 'background-image': "url('#{thumbnail.medium.url}')"

        # Home
        # when 'page.home'
        #   # スライダー
        #   if photo = acf.slider01
        #     (@$ '.archive-media--home__slider').css 'background-image': "url(\"#{photo.url}\")"
        #     image = new Image()
        #     image.onload = ->
        #       $self.addClass 'loaded'
        #     image.src = photo.url

        # About
        when 'page.about'
          # 背景スクロール対象の設定
          media.scrollel = @$ '.js-scroll'
          # メンバー一覧を描画
          $members_html = @$ '.members'
          members = (acf.member_lists).split('<br />').map (member) -> # 行ごとに配列化
            return member.replace /^\s+|\s+$/g, ''
          members = $.grep members, (e) -> return e # 0/false/undifinedな要素を削除
          season = '2000S'
          for index, member of members
            if member.indexOf('〜') > -1
              season = member.slice(0, -1).replace('S', '.0').replace('A', '.5')
            else
              if member.charAt(0) is '#'
                member = member.slice 1
                current_class = "member member-th col-sm-12 col-xs-12"
                $members_html.append(
                  ($ '<li />').addClass(current_class).append(
                    ($ '<h4 />').append(
                      ($ '<i />').addClass 'fa fa-graduation-cap'
                    ).append(
                      ($ '<span />').html member
                    )
                  )
                )
              else
                current_class = "member member-td col-sm-2 col-xs-4"
                current_class = current_class + " first" if season is '2013.0'
                $members_html.append(
                  ($ '<li />').addClass(current_class).attr(
                    'data-member-id': index
                    'data-since': season
                  ).append(
                    ($ '<span />').html member
                  )
                )
          # メンバー年表
          td = new Date()
          month = if m = (td.getMonth()+1) < 4 then -0.5 else if m < 10 then 0 else 0.5
          season_min = 2013.0
          season_max = parseFloat(td.getFullYear()) + month
          $handle = @$ '.handle-holder'
          $handle_label = @$ '.handle-label-text'
          $members = @$ '.member-td'
          previous_season = null

          drag_event = ->
            percentage = ui.parse_pixel($handle.css 'left') / 378
            season = ( ~~(( season_max - season_min ) * percentage * 2) ) / 2 + season_min
            season_label = '2000/Spr'
            if season.toString().indexOf('.5') > -1
              season_label = season.toString().replace '.5', '/Aut'
            else
              season_label = "#{season}/Spr"
            # ラベル
            $handle_label.text season_label
            # メンバー
            if season isnt previous_season
              $members.each ->
                if parseFloat(($ @).data('since')) <= season
                  ($ @).addClass 'visible'
                else
                  ($ @).removeClass 'visible'
            # 変更を監視
            previous_season = season

          $handle.draggable
            addClasses: no
            snap: no
            axis: 'x'
            containment: '.bar'
            drag: ->
              drag_event()


      if ctype is 'single'
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

    backToIndex: ->
      $app.navigate '/', yes

    # in Archive
    navigateToSingle: (event) ->
      console.log 'navigateToSingle', @model.get('ptype')
      event.preventDefault()
      url = ui.parse_uri(@model.get 'url').path
      if @model.get('ptype') is 'photolog'
        media.galleryMode = on
        $app.navigate url, yes
      else
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
      url = ui.parse_uri(@model.get 'previous_url').path
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
      url = ui.parse_uri(@model.get 'next_url').path
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
        media.galleryBoxView = new GalleryBoxView media.galleryBox
        media.contactBoxView = new ContactBoxView media.contactBox
        @$title = $ 'title'

    # Page
    index: (text='') ->
      # console.log 'index', text
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
        ## fetchのための変数
        ## -------------------------------------

        # 引数からクエリをセット
        media.query = query

        # 遷移常態を変数に待避
        pre_ctype = media.prequery.api
        pre_ptype = media.prequery.post_type
        ctype = media.query.api
        ptype = media.query.post_type

        # 読み込むページ数をセット
        if (not media.query.page) or (pre_ptype isnt ptype)
          # ページ数を指定していない場合 or 投稿タイプが変わった場合
          media.query.page = 1

        page = media.query.page

        # console.log "#{pre_ctype}.#{pre_ptype} ==> #{ctype}.#{ptype}.P#{page}"

        ## 読み込む前の画面を準備
        ## -------------------------------------

        @fetching = yes
        # ui.progress on

        # トップページの判定
        $home_el = $ '.ui-header'
        if "#{ctype}.#{ptype}" is 'page.home'
          $home_el.addClass 'home'
        else
          $home_el.removeClass 'home'

        # お問い合わせモードの判定
        if pre_ctype and "#{ctype}.#{ptype}" is 'page.contact'
          media.contactMode = on

        # 上部へスクロールをするかの判定(P1 and notギャラリー)
        do_scroll = media.query.page is 1 and not media.contactMode and not media.galleryMode
        if do_scroll
          ui.scroll.swing()
          ui.pageLoader on # ローダーの表示

        # デバッグ出力
        # console.log """
        #   galleryMode: #{media.galleryMode}
        #   contactMode: #{media.contactMode}
        #   do_scroll  : #{do_scroll}"""
        # console.log "API(#{media.query.api}) リクエスト準備:", media

        ## AJAXリクエストを実行
        ## -------------------------------------
        $.when($api[media.query.api] media.query)
          .done (data) =>
            ## 次回fetchの準備
            ## -------------------------------------

            # デバッグ出力
            # console.log "API(#{media.query.api}) リクエスト結果:", data

            # 次ページの有無を確認
            media.next = if (data.pages - media.query.page) > 0 then yes else no

            ## ショートカットの作成
            ## -------------------------------------

            @fetching = no
            ui.progress off
            ui.pageLoader off

            ## 画面を新しいページにあわせて書き換え
            ## -------------------------------------

            ## モバイル版メニューバーを閉じる
            ($ '.ui-navi-menu').removeClass 'visible'
            ($ '.ui-navi-search').removeClass 'visible'

            # メニューバーを更新
            media.containerView.updateMenubar()

            # アイテムの初期化
            if media.query.page is 1 and not media.contactMode and not media.galleryMode
              media.container.reset()

            # コンテナを全幅にするか
            ui.containerWide (media.query.post_type is 'about')

            # ページタイトル
            switch ctype
              when 'archive'
                media.containerView.setTitle "#{ptype}s", "#{ptype}s"
              when 'single'
                media.containerView.setTitle data.post?.title_plain, "#{ptype}s"
              when 'page'
                media.containerView.setTitle data.page?.title_plain, null

            # デフォルトに変数を指定
            defaults =
              ctype: ctype
              ptype: ptype
              pre_ctype: pre_ctype
              pre_ptype: pre_ptype

            ## 1. パンくずナビ生成
            ## 2. 取得した投稿アイテムをコレクションに追加
            ## -------------------------------------

            switch ctype
              when 'archive'
                media.galleryBoxView.close()
                ui.createBreadCrumbs media.query, null
                # Masonry
                media.containerView.initMasonry() if ptype is 'photolog'
                # Add
                for post in data.posts
                  post = _.extend defaults, post
                  media.container.add new Content post

              when 'single'
                post = _.extend defaults, data.post
                ui.createBreadCrumbs media.query, post
                post = _.extend post,
                  id: data.post.id + 10000
                  next_url: data.next_url
                  previous_url: data.previous_url
                # Add
                if media.galleryMode
                  media.galleryBox.reset()
                  media.galleryBox.add new Gallery post
                else
                  media.container.add new Content post

              when 'page'
                post = _.extend defaults, data.page
                ui.createBreadCrumbs media.query, post
                # Add
                if media.contactMode
                  media.contactBox.reset()
                  media.contactBox.add new Contact post
                else
                  media.container.add new Content post

            ## アイテムの描画後に必要な処理
            ## -------------------------------------

            switch "#{ctype}.#{ptype}"
              when 'page.about'
                # 動きをセット
                wow = new WOW
                  boxClass: 'animate'
                  offset: 0
                  mobile: no
                wow.init()
                ui.gmap ($ '#map_canvas'), 35.3876811, 139.4265623, 14, "慶應義塾大学湘南藤沢キャンパス 大木研究室"

            ## イベントをreturn
            ## -------------------------------------

            # 実行したクエリをバックアップ
            media.prequery = media.query

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
    galleryBox: new GalleryBox
    contactBox: new ContactBox
    containerView: null
    galleryBoxView: null
    contactBoxView: null
    masonryMode: off
    galleryMode: off
    contactMode: off
    query:
      api: 'default'
      post_type: null
      page: 1
      post_id: null
      search: no
      text: null
    prequery:
      api: null
      post_type: null
      page: null
    next: null
    search:
      focusEnable: yes
    sign_in: $body.hasClass 'signed_in'
    scrolltop: null
    scrollel: null

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
      url = ui.parse_uri($target.attr 'href').path
      $app.navigate url, yes

  # パンくずナビ
  ($ '.js-breadcrumbs a').on
    'click': (event) ->
      event.preventDefault()
      $target = $ event.currentTarget
      url = ui.parse_uri($target.attr 'href').path
      $app.navigate url, yes

  # ===================================
  # Actions
  # ===================================

  $win.on 'resize scroll', _.throttle (event) ->
    winheight     = $win.height()
    docheight     = $doc.height()
    scrollheight  = $doc.scrollTop()

    winwidth      = $win.width()
    docwidth      = $doc.width()

    # loadNext
    if docheight < window.scrollY + winheight + 1200
      $app.loadNext()

    # ギャラリーのリサイズ
    media.containerView.fitGallery()
    media.galleryBoxView.fitGallery()

    # 背景をスクロール
    if media.scrollel
      percent = 100 - (scrollheight / winheight * 100)
      # if 0 <= percent and percent <= 100
      media.scrollel.css 'background-position-y', "#{percent}%"

    # スクロールアイコンの表示／非表示
    if 50 < scrollheight
      return if media.scrolltop
      $body.addClass 'scroll'
      media.scrolltop = yes
    else
      return if not media.scrolltop
      $body.removeClass 'scroll'
      media.scrolltop = no

  , 20 # 12ミリ秒に1回しか実行できないように


  $doc.on 'click', '.ui-scrollto', ->
    ui.scroll.fast()

  # ===================================
  # Key Actions
  # ===================================

  $doc.on 'keydown', _.debounce (event) ->
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
  , 240 # 最後に実行されてから240ミリ秒以内にもう一度実行されたらabort、実行されなければexec

  $doc.on 'keyup', _.debounce (event) ->
    switch event.keyCode
      when 83 # s, 検索窓をフォーカス
        # if media.search.focusEnable and ($ ':focus').attr('id') isnt 's'
        #   ($ '#s').focus()
        # media.search.focusEnable = yes
        return
  , 240 # 最後に実行されてから240ミリ秒以内にもう一度実行されたらabort、実行されなければexec

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


  # ===================================
  # Footer Google Maps
  # ===================================

  ui.gmap ($ '#map_canvas_footer')
  ui.gmap ($ '#map_canvas'), 35.3876811, 139.4265623, 14, "慶應義塾大学湘南藤沢キャンパス 大木研究室"

  # ===================================
  # Delay load images
  # ===================================

  ui.imageload()

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
