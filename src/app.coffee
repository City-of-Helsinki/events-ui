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

requirejs ['backbone', 'backbone.marionette', 'jquery', 'app/models', 'app/jade'], (Backbone, Marionette, $, models, jade) ->
    app = new Backbone.Marionette.Application()

    app.addInitializer (opts) ->
        console.log app_settings
        eventList = new models.EventCollection()
        eventList.fetch
            success: ->
                $target = $('.content ul')
                $target.empty()
                eventList.each (e) ->
                    t = jade.template 'event-list-item', e.attributes
                    console.log t
                    $target.append $(t)

    $ ->
        app.start()
