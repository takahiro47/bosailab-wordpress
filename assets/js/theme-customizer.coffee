###
Theme Customizer enhancements for a better user experience.

Contains handlers to make Theme Customizer preview reload changes asynchronously.
Things like site title and description changes.
###
(($) ->
  # Site title and description.
  wp.customize 'blogname', (value) ->
    value.bind (to) ->
      ($ '.site-title').text to

  wp.customize 'blogdescription', (value) ->
    value.bind (to) ->
      ($ '.site-description').text to

  # Header text color.
  wp.customize 'header_textcolor', (value) ->
    value.bind (to) ->
      if 'blank' is to
        if 'remove-header' is _wpCustomizeSettings.values.header_image
          ($ '.home-link').css 'min-height', '0'
        ($ '.site-title, .site-description').css
          clip: 'rect(1px, 1px, 1px, 1px)'
          position: 'absolute'

      else
        ($ '.home-link').css 'min-height', '230px'
        ($ '.site-title, .site-description').css
          clip: 'auto'
          color: to
          position: 'relative'

) jQuery