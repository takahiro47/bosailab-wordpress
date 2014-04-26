# http://qiita.com/ktty1220/items/f1bb5b4eb48839de8394
(->
  'use strict'

  # ログのスタイル
  logStyles =
    timestamp:
      color: "gray"

    label:
      color: "white"
      "border-radius": "2px"

    event:
      color: "blue"
      "font-weight": "bold"
      "font-size": "110%"

  # ラベルの色
  labelColors =
    Model: "red"
    Collection: "purple"
    View: "green"
    Router: "black"

  debugEvents = (parts) ->
    (prefix) ->
      @__debugEvents = @__debugEvents or {}
      if prefix is false
        return @off("all", @__debugEvents.log, this)
      else @__debugEvents.prefix = prefix or ""  if prefix isnt true
      if "log" of @__debugEvents

        # イベント登録済チェック(二重登録防止)
        if "_events" of this and "all" of @_events
          exists = _.some(@_events.all, (item) ->
            item.callback is @__debugEvents.log and item.context is this
          , this)
          return  if exists
      else

        # イベント発火時の関数作成
        labelCss = _.extend(logStyles.label,
          background: labelColors[parts]
        )
        css =
          timestamp: _.map(logStyles.timestamp, (val, key) ->
            key + ":" + val
          ).join(";")
          label: _.map(labelCss, (val, key) ->
            key + ":" + val
          ).join(";")
          event: _.map(logStyles.event, (val, key) ->
            key + ":" + val
          ).join(";")

        @__debugEvents.log = (eventName) ->
          labelName = parts
          labelName += ":" + @__debugEvents.prefix  if @__debugEvents.prefix
          console.debug "%c%s %c%s%c %s", css.timestamp, new Date().toString().match(/(\d+:\d+:\d+)/)[1], css.label, " " + labelName + " ", css.event, eventName, Array::slice.call(arguments_, 1)
          return

      @on "all", @__debugEvents.log, this
      return

  # Backboneの各クラスのプロトタイプにdebugEvents()メソッド付加
  _.each labelColors, (val, key) ->
    Backbone[key]::debugEvents = debugEvents(key)
    return

  return
)()