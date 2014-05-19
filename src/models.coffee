define ['underscore', 'backbone', 'backbone-pageable', 'spin'], (_, Backbone, PageableCollection, Spinner) ->
    backend_base = app_settings.backend_url

    class RESTFrameworkCollection extends PageableCollection
        parse: (resp, options) ->
            # Transform Django REST Framework response into PageableCollection
            # compatible structure.
            for obj in resp.data
                if not obj.resource_uri
                    continue
                # Remove trailing slash
                s = obj.resource_uri.replace /\/$/, ''
                obj.id = s.split('/').pop()
            super [resp.meta, resp.data], options

    class LEModel extends Backbone.Model
        # FIXME/THINKME: Should we take care of translation only in
        # the view level? Probably.
        get_text: (attr) ->
            val = @get attr
            if attr in @translated_attrs
                return p13n.get_translated_attr val
            return val
        toJSON: (options) ->
            data = super()
            if not @translated_attrs
                return data
            for attr in @translated_attrs
                if attr not of data
                    continue
                data[attr] = p13n.get_translated_attr data[attr]
            return data

        urlRoot: ->
            return "#{backend_base}/#{@resource_name}/"

    class LECollection extends RESTFrameworkCollection
        initialize: ->
            @filters = {}

        url: ->
            obj = new @model
            return "#{backend_base}/#{obj.resource_name}/"

        setFilter: (key, val) ->
            if not val
                if key of @filters
                    delete @filters[key]
            else
                @filters[key] = val

        fetch: (options) ->
            if options?
                options = _.clone options
            else
                options = {}

            data = _.clone @filters
            if options.data?
                data = _.extend data, options.data
            options.data = data

            if options.spinner_target
                spinner = new Spinner().spin(options.spinner_target)
                success = options.success
                error = options.error

                options.success = (collection, response, options) ->
                    spinner.stop()
                    success?(collection, response, options)

                options.error = (collection, response, options) ->
                    spinner.stop()
                    error?(collection, response, options)

            super options

    class Event extends LEModel
        resource_name: 'event'
        translated_attrs: ['name', 'url', 'description']

    class EventCollection extends LECollection
        model: Event

    exports =
        Event: Event
        EventCollection: EventCollection

    return exports
