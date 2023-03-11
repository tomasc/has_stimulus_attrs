# HasStimulusAttrs

[![HasStimulusAttrs](https://github.com/tomasc/has_stimulus_attrs/actions/workflows/ruby.yml/badge.svg)](https://github.com/tomasc/has_stimulus_attrs/actions/workflows/ruby.yml)

Helper methods for dealing with [stimulus](https://stimulus.hotwired.dev/) data attributes.

Relies on [`has_dom_attrs`](github.com/tomasc/has_dom_attrs) and [`stimulus_helpers`](github.com/tomasc/stimulus_helpers).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add has_stimulus_attrs

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install has_stimulus_attrs

## Usage

Include `HasStimulusAttrs` in your class and define a `controller_name` class method:

```ruby
class ModalComponent
  include HasStimulusAttrs

  def self.controller_name
    "modal-component"
  end
end
```

`controller_name` can also be defined in a base class and dynamically resolved:

```ruby
class ApplicationComponent
  include HasStimulusAttrs

  def self.controller_name
    self.name.underscore.dasherize
  end
end

class DetailsComponent < ApplicationComponent
end

DetailsComponent.new.controller_name
# => "details-component"
```

You can then use the included class methods to easily set stimulus attributes on
your class:

```ruby
class ModalComponent < ApplicationComponent
  # Controller
  has_stimulus_controller # sets the "controller" data attribute using :controller_name by default
  has_stimulus_controller "click-outside"
  has_stimulus_controller "scroll-lock", if: :open? # conditionally add the controller
  has_stimulus_controller "scroll-lock", unless: :closed? # conditionally add the controller

  # Action
  has_stimulus_action "click", "onClick"
  has_stimulus_action "click", "onClick", if: :open?

  # Class
  has_stimulus_class "open", "modal--open"
  has_stimulus_class "width", -> { "modal--#{width}" } # resolve the class name dynamically

  # Outlet
  has_stimulus_outlet "outlet", ".selector"

  # Param
  has_stimulus_param id: 123
  has_stimulus_param id: -> { id }

  # Target
  has_stimulus_target "target"
  has_stimulus_target "target", controller: "other-controller"

  # Value
  has_stimulus_value "id", 123
  has_stimulus_value "id", -> { id }
  has_stimulus_value "id", -> { id }, controller: "other-controller"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/has_stimulus_attrs.
