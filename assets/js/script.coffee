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
  # $api =
  #   domain: ($ '#api').data 'url'

  #   home: (data = {}) ->
  #     return $.ajax "#{$api.domain}/?feed=json&callback=callback",
  #       type: 'GET'
  #       data: data
  #       dataType: 'jsonp'

  #   archive: (data = {}) ->
  #     return $.ajax "#{$api.domain}/#{data.post_type}/?json=get_posts&page=#{data.page}",
  #       type: 'GET'
  #       dataType: 'jsonp'

  #   single: (data = {}) ->
  #     return $.ajax "#{$api.domain}/#{data.post_type}/?json=get_post&post_id=#{data.post_id}",
  #       type: 'GET'
  #       dataType: 'jsonp'

  #   page: (data = {}) ->
  #     return $.ajax "#{$api.domain}/?json=get_page&page_slug=#{data.post_type}",
  #       type: 'GET'
  #       dataType: 'jsonp'

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

    sample_image_url: (text) ->
      text.match /https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:@&=+$,%#]+\.(jpg|jpeg|gif|png|svg)/g

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

    initMaps: ($el=null, lat=35.3876811, lng=139.4265623, zoom=14, title='慶應義塾大学湘南藤沢キャンパス 大木研究室') ->
      unless $el then $el = ($ '#map_canvas')
      console.log 'initMaps', $el
      if $el.length
        latlng = new google.maps.LatLng lat, lng
        myOptions =
          zoom: zoom
          center: latlng
          disableDefaultUI: no
          scrollwheel: no
          # mapTypeId: google.maps.MapTypeId.ROADMAP
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

    updateMenubar: ->
      $menubar0 = $ ".menu-item a[href='/#{media.query.post_type}']"
      $menubar1 = $ ".menu-item a[href='/#{media.query.post_type}/']"
      ($ '.navigation-menu').find('.menu-item').removeClass 'current-menu-item'
      $menubar0.parents('.menu-item').addClass 'current-menu-item'
      $menubar1.parents('.menu-item').addClass 'current-menu-item'
      return

  ui.initMaps()

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
  # Actions
  # ===================================

  $win.on 'resize scroll', _.throttle (event) ->
    winheight     = $win.height()
    docheight     = $doc.height()
    scrollheight  = $doc.scrollTop()

    winwidth      = $win.width()
    docwidth      = $doc.width()

    # loadNext
    # if docheight < window.scrollY + winheight + 1200
    #   $app.loadNext()

    # ギャラリーのリサイズ
    # media.containerView.fitGallery()
    # media.galleryBoxView.fitGallery()

    # 背景をスクロール
    # if media.scrollel
    #   percent = 100 - (scrollheight / winheight * 100)
    #   # if 0 <= percent and percent <= 100
    #   media.scrollel.css 'background-position-y', "#{percent}%"

    # # スクロールアイコンの表示／非表示
    # if 50 < scrollheight
    #   return if media.scrolltop
    #   $body.addClass 'scroll'
    #   media.scrolltop = yes
    # else
    #   return if not media.scrolltop
    #   $body.removeClass 'scroll'
    #   media.scrolltop = no

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
  # Delay load images
  # ===================================

  $.fn.imageload = ->
    @each ->
      $el = $ @ # .archive-media--photograph-wrap
      $photograph = $el.find '.archive-media--photograph'
      if uri = ui.sample_image_url($photograph.css 'background-image')
        image = new Image()
        image.onload = => $el.addClass 'loaded'
        image.src = uri[0]
      else
        ($loader = $el.find '.ui-loader').remove()
      return

  ($ '.archive-media--photograph-wrap').imageload()


  # ===================================
  # Run Animation via WOW
  # ===================================

  wow = new WOW
    boxClass:     'animate'
    animateClass: 'animated'
    offset:       0

  wow.init()

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
