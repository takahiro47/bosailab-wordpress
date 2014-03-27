###
Functionality specific to Twenty Thirteen.
Provides helper functions to enhance the theme experience.
###
(($) ->
  body = ($ 'body')
  _window = $(window)

  ###
  Adds a top margin to the footer if the sidebar widget area is higher
  than the rest of the page, to help the footer always visually clear
  the sidebar.
  ###
  $ ->
    if body.is '.sidebar'
      sidebar = ($ '#secondary .widget-area')
      secondary = (if (0 is sidebar.length) then -40 else sidebar.height())
      margin =
        ($ '#tertiary .widget-area').height() - ($ '#content').height() - secondary
      ($ '#colophon').css 'margin-top',
        margin + 'px' if margin > 0 and _window.innerWidth() > 999


  ###
  Enables menu toggle for small screens.
  ###
  ( ->
    nav = ($ '#site-navigation')
    button = undefined
    menu = undefined
    return  unless nav
    button = nav.find('.menu-toggle')
    return  unless button

    # Hide button if menu is missing or empty.
    menu = nav.find('.nav-menu')
    if not menu or not menu.children().length
      button.hide()
      return
    ($ '.menu-toggle').on 'click.twentythirteen', ->
      nav.toggleClass 'toggled-on'
  )()

  ###
  Makes 'skip to content' link work correctly in IE9 and Chrome for better
  accessibility.
  @link http://www.nczonline.net/blog/2013/01/15/fixing-skip-to-content-links/
  ###
  _window.on 'hashchange.twentythirteen', ->
    element = document.getElementById location.hash.substring(1)
    if element
      unless /^(?:a|select|input|button|textarea)$/i.test(element.tagName)
        element.tabIndex = -1
      element.focus()

  ###
  Arranges footer widgets vertically.
  ###
  if $.isFunction $.fn.masonry
    columnWidth = (if body.is('.sidebar') then 228 else 245)
    ($ '#secondary .widget-area').masonry
      itemSelector: '.widget'
      columnWidth: columnWidth
      gutterWidth: 20
      isRTL: body.is '.rtl'

) jQuery