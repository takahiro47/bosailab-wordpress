# window.init = ->
$ = jQuery.noConflict()
$ ->
  doc = ($ document)

  # .onload
  ($ 'html').addClass 'onload'

  # top link
  ($ '#top').on
    'click': (e) ->
      ($ 'body').animate
        scrollTop: 0
      , 'fast'
      e.preventDefault()

  # scrolling links
  doc.scroll (e) ->
    if doc.scrollTop() > 5
      if added then return
      added = yes
      ($ 'body').addClass 'scroll'
    else
      ($ 'body').removeClass 'scroll'
      added = no

  # 複数行における省略
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

