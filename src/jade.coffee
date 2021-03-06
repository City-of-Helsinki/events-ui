define 'app/jade', ['underscore', 'jquery', 'i18next', 'app/p13n'], (_, $, i18n, p13n) ->
    # Make sure jade runtime is loaded
    if typeof jade != 'object'
        throw "Jade not loaded before app"

    class Jade
        get_template: (name) ->
            key = "views/templates/#{name}"
            if key not of JST
                throw "template #{name} not loaded"
            template_func = JST[key]
            return template_func

        get_template_i18n: (name) ->
            template_func = @get_template name
            return (data) ->
                data = _.clone data
                data.t = i18n.t
                data.t_attr = @t_attr
                template_func data

        t_attr: (attr) ->
            return p13n.get_translated_attr attr

        template: (name, locals) ->
            if locals?
                if typeof locals != 'object'
                    throw "template must get an object argument"
            else
                locals = {}
            func = @get_template_i18n name
            template_str = func locals
            return $.trim template_str

    return new Jade
