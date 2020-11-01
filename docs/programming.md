# Notes about Octoshell programming 

Here you can find notes about Octoshell programming, if you want to change/add something.

# How Octoshell is constructed

Octoshell is an Runy-on-Rails application. Almost all functions are implemented
via modules (RoR engines). Main app contains **User** model, which allows users
to register and do minimal actions. Key modules: **Core** (contains models
**Project**, **Cluster**, etc.) and **Face** (contains default pages layout and
main menu).

# UI

All views use slim template engine. You can use others, e.g. **erb**, but it
is not recommended. Bootstrap 5, JQuery, FontAwesome are included yet, feel free
to use them.

## Fields autocompletion

Example of autocomplete user select field:

```
  = f.autocomplete_field :id, label: t("user"), source: main_app.users_path
```

If you want to implement autocomplete for your fields, you should implement
in your contoller a code similar to this (taken from User model):

```
  # User - change to your model
  # format.json - needed for autocomplete
  format.json do
    @users = User.finder(params[:q])
    
    # user rights check - admins get more data
    # This is optional
    # Important: records = list of records, total = number of records

    if User.superadmins.include? current_user
      render json: { records: @users.page(params[:page]).per(params[:per]),
                     total: @users.count }
    else
      render json: { records: @users.page(params[:page]).per(params[:per])
                                    .map{ |u| { id: u.id,
                                                text: u.full_name_with_cut_email }},
                     total: @users.count }
    end
  end
```

## Flash-notifications

If you want to show to user a short flash message on the next shown page,
use these helpers:

```
  flash_message TYPE, message      # for NEXT request
  flash_now_message TYPE, message  # in THIS request
```

Here TYPE is a css style name. We recommend to use 'success',
'ok', 'error', 'danger', 'alert', 'warn', 'warning', 'notice', 'info'.
Other values will be interpreted as css-class name, it should exist in your
assets.

Several helper call will create several messages (so, do not call **flash()**
directly!). Message text is **not** filtered, so you can insert html-tags,
links etc, but also be extremely careful if you insert user text here.

## Notify
Persistent (almost) messages to user are implemented by **Notify** class.
Notify class is declared in Core module. It contains:

- message:        text
- count:          (opt) a number of something
- category:       0=per-user message, 1=site-wide message, other=not show by default
- kind:           (opt) string to select handler, nil = just show (default)
- show_from:      (opt) show only after this time
- show_till:      (opt) show only till this time
- active:         nil/int. 0 = do not show (nil/1 = show)
- sourceable:     object, associated with this. For category=0 it must be User
- linkable:       (opt) linked object

In ROOT/config/initializers/notice.rb (or in other initializer) you can register
a handler for custom notify kind:

```
Core::Notice.register_kind 'mykind' do |notice, user, params, request|
  # nil
  # [:warn, "Your account is blocked now. Please, contact administrator here #{notice.message}."]
end
```

Handler receives kind string and block. Block is called to check if message
should be shown. It returns nil (if don't show) or an array of two elements:
css-style name ('success', 'ok', etc, see above) and text.
**Attention!** text will be show without html sanation!
