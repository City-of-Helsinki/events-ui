requirejs.config
    baseUrl: 'vendor'
    shim:
        backbone:
            deps: ['underscore', 'jquery']
            exports: 'Backbone'
        typeahead:
            deps: ['jquery']
        'leaflet.awesome-markers':
            deps: ['leaflet']
    paths:
        app: '../js'
        moment: 'moment-with-langs'


requirejs ['backbone', 'backbone.marionette', 'jquery', 'moment', 'app/models', 'app/jade'], (Backbone, Marionette, $, moment, models, jade) ->
    moment.lang 'fi'
    app = new Backbone.Marionette.Application()
    class AppView extends Backbone.Marionette.View
        el: 'main'
        render: ->
            html = jade.template 'base'
            @$el.html $(html)
            @content = new Backbone.Marionette.Region
                el: @$el.find '.page-content'
            this

    class Router extends Backbone.Marionette.AppRouter
        initialize: ->
            @slider = new PageSlider $('body')
        routes:
            '': 'home'
        home: ->
            console.log 'home'
            view = new AppView()
            view.render()

    class EventListItemView extends Backbone.Marionette.ItemView
        tagName: 'li'
        className: 'table-view-cell'
        templateHelpers:
            time: (time, fmt) ->
                m = moment time
                if not fmt?
                    fmt = 'LLLL'
                return m.format fmt
        getTemplate: ->
            return jade.get_template_i18n 'event-list-item'

    class EventListView extends Backbone.Marionette.CollectionView
        tagName: 'ul'
        className: 'table-view'
        itemView: EventListItemView

    app.addInitializer (opts) ->
        router = new Router()
        Backbone.history.start()
        eventList = new models.EventCollection()
        eventList.fetch
            data:
                start: 'today'
                end: 'today'
                sort: 'days_left,start_time'
            success: ->
                listView = new EventListView
                    collection: eventList
                listView.render()
                $(".page-content").html listView.$el
                #slider.slidePage $target

    $ ->
        app.start()
