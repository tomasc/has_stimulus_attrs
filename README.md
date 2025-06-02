# HasStimulusAttrs

[![HasStimulusAttrs](https://github.com/tomasc/has_stimulus_attrs/actions/workflows/ruby.yml/badge.svg)](https://github.com/tomasc/has_stimulus_attrs/actions/workflows/ruby.yml)

A Ruby DSL for managing [Stimulus.js](https://stimulus.hotwired.dev/) data attributes in component-based architectures.

Built on [`has_dom_attrs`](https://github.com/tomasc/has_dom_attrs) and [`stimulus_helpers`](https://github.com/tomasc/stimulus_helpers).

## Installation

```bash
bundle add has_stimulus_attrs
```

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

DetailsComponent.controller_name
# => "details-component"
```

Use the DSL methods to define Stimulus attributes:

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
  has_stimulus_param :id, 123
  has_stimulus_param :id, -> { id }

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

```bash
bin/setup    # Install dependencies
bin/console  # Interactive prompt
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomasc/has_stimulus_attrs.
