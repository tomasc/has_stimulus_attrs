# HasStimulusAttrs

## Overview

HasStimulusAttrs is a Ruby gem that provides a clean, declarative DSL for managing [Stimulus.js](https://stimulus.hotwired.dev/) data attributes in Ruby classes. It's particularly useful for component-based architectures in Rails applications where you need to generate Stimulus-compatible HTML attributes programmatically.

## Core Concepts

### What Problem Does This Solve?

When building Rails applications with Stimulus.js, you often need to generate HTML elements with specific data attributes that Stimulus uses:
- `data-controller`
- `data-action`
- `data-[controller]-target`
- `data-[controller]-value`
- etc.

Managing these attributes manually can become cumbersome, especially when dealing with:
- Multiple controllers on a single element
- Dynamic values that change based on component state
- Conditional attributes
- Consistent naming conventions

HasStimulusAttrs solves these problems by providing a Ruby DSL that handles the complexity of generating proper Stimulus attributes.

### How It Works

The gem works by:
1. Including the `HasStimulusAttrs` module in your Ruby class
2. Defining a `controller_name` method that returns your Stimulus controller's identifier
3. Using the provided DSL methods to declare what Stimulus attributes your component needs
4. The gem automatically generates the correct `dom_data` hash with properly formatted Stimulus attributes

## Architecture

### Module Structure

```
HasStimulusAttrs
├── Includes HasDomAttrs (for DOM attribute management)
├── Includes StimulusHelpers (for Stimulus-specific formatting)
└── Provides ClassMethods when included
```

### Key Dependencies

1. **has_dom_attrs** - Provides the underlying DOM attribute management functionality
2. **stimulus_helpers** - Provides helper methods for formatting Stimulus-specific attributes
3. **activesupport** - Used for core Ruby extensions (like `blank?`)

## API Reference

### Including the Module

```ruby
class MyComponent
  include HasStimulusAttrs
  
  def self.controller_name
    "my-component"
  end
end
```

### Available Methods

#### `has_stimulus_controller(name = controller_name, **options)`

Adds a Stimulus controller to the element.

```ruby
# Use default controller name
has_stimulus_controller

# Add additional controller
has_stimulus_controller "click-outside"

# Conditional controller
has_stimulus_controller "modal", if: :open?

# Dynamic controller name
has_stimulus_controller -> { "theme-#{current_theme}" }
```

#### `has_stimulus_action(event, action, controller: nil, **options)`

Defines a Stimulus action.

```ruby
# Basic action
has_stimulus_action "click", "handleClick"

# Action for different controller
has_stimulus_action "submit", "save", controller: "form-controller"

# Conditional action
has_stimulus_action "keydown", "handleEscape", if: :keyboard_enabled?

# Dynamic action name (v0.2.2+)
has_stimulus_action "click", -> { admin? ? "adminAction" : "userAction" }
```

#### `has_stimulus_class(name, value, controller: nil, **options)`

Defines CSS classes managed by Stimulus.

```ruby
# Static class
has_stimulus_class "active", "component--active"

# Dynamic class
has_stimulus_class "size", -> { "component--#{size}" }

# Using method
has_stimulus_class "theme", :theme_class_name
```

#### `has_stimulus_outlet(name, value, controller: nil, **options)`

Defines Stimulus outlets.

```ruby
# CSS selector outlet
has_stimulus_outlet "modal", "#main-modal"

# Dynamic outlet
has_stimulus_outlet "target", -> { "##{dom_id}" }
```

#### `has_stimulus_param(name, value, controller: nil, **options)`

Defines Stimulus parameters.

```ruby
# Static param
has_stimulus_param :url, "/api/endpoint"

# Dynamic param
has_stimulus_param :id, -> { model.id }

# Using method
has_stimulus_param :config, :configuration_json
```

#### `has_stimulus_target(name, controller: nil, **options)`

Marks element as a Stimulus target.

```ruby
# Basic target
has_stimulus_target "button"

# Target for different controller
has_stimulus_target "input", controller: "form-controller"
```

#### `has_stimulus_value(name, value = nil, controller: nil, **options)`

Defines Stimulus values.

```ruby
# Static value
has_stimulus_value "endpoint", "/api/data"

# Dynamic value
has_stimulus_value "userId", -> { current_user.id }

# Using method name as value
has_stimulus_value :timeout  # calls timeout method
```

### Options

All methods support these options:
- `:if` - Include attribute only if condition is truthy
- `:unless` - Include attribute unless condition is truthy
- `:controller` - Specify a different controller (can be string or Proc)

## Usage Patterns

### Basic Component

```ruby
class DropdownComponent
  include HasStimulusAttrs
  
  attr_reader :open
  
  def self.controller_name
    "dropdown"
  end
  
  has_stimulus_controller
  has_stimulus_action "click", "toggle"
  has_stimulus_class "open", "dropdown--open"
  has_stimulus_value "open", -> { open }
  has_stimulus_target "menu"
end
```

### Component with Multiple Controllers

```ruby
class ModalComponent
  include HasStimulusAttrs
  
  def self.controller_name
    "modal"
  end
  
  has_stimulus_controller
  has_stimulus_controller "trap-focus"
  has_stimulus_controller "click-outside", if: :dismissible?
  
  has_stimulus_action "click", "close", controller: "click-outside"
  has_stimulus_action "keydown.esc", "close"
end
```

### Dynamic Component

```ruby
class ThemeComponent
  include HasStimulusAttrs
  
  attr_reader :theme, :user_preferences
  
  def self.controller_name
    "theme"
  end
  
  has_stimulus_controller
  has_stimulus_value "theme", -> { user_preferences[:theme] || "light" }
  has_stimulus_class "mode", -> { "theme--#{theme}" }
  has_stimulus_param :config, -> { theme_configuration.to_json }
end
```

### Inheritance Pattern

```ruby
class ApplicationComponent
  include HasStimulusAttrs
  
  def self.controller_name
    name.underscore.dasherize
  end
end

class AlertComponent < ApplicationComponent
  # Inherits controller_name as "alert-component"
  has_stimulus_controller
  has_stimulus_action "click", "dismiss"
  has_stimulus_class "type", -> { "alert--#{type}" }
end
```

## Integration with Rails

### ViewComponent Example

```ruby
class ButtonComponent < ViewComponent::Base
  include HasStimulusAttrs
  
  def self.controller_name
    "button"
  end
  
  has_stimulus_controller
  has_stimulus_action "click", "handleClick"
  has_stimulus_value "loading", -> { loading? }
  
  def call
    tag.button(**dom_attrs) do
      content
    end
  end
end
```

### Phlex Example

```ruby
class Card < Phlex::HTML
  include HasStimulusAttrs
  
  def self.controller_name
    "card"
  end
  
  has_stimulus_controller
  has_stimulus_action "mouseenter", "highlight"
  has_stimulus_action "mouseleave", "unhighlight"
  
  def template
    div(**dom_attrs) do
      yield
    end
  end
end
```

## Advanced Usage

### Conditional Controllers

```ruby
class ToggleComponent
  include HasStimulusAttrs
  
  has_stimulus_controller "toggle"
  has_stimulus_controller "animation", if: :animated?
  has_stimulus_controller "a11y", unless: :accessibility_disabled?
  
  def animated?
    @options[:animate] != false
  end
  
  def accessibility_disabled?
    @options[:disable_a11y] == true
  end
end
```

### Dynamic Controller Names

```ruby
class PolymorphicComponent
  include HasStimulusAttrs
  
  has_stimulus_controller -> { "#{record.class.name.underscore}-controller" }
  has_stimulus_value "id", -> { record.id }
  has_stimulus_value "type", -> { record.class.name }
end
```

### Complex Actions

```ruby
class FormComponent
  include HasStimulusAttrs
  
  # Multiple actions on same event
  has_stimulus_action "submit", "validate"
  has_stimulus_action "submit", "save"
  
  # Actions with modifiers
  has_stimulus_action "keydown.enter", "submit"
  has_stimulus_action "input->debounced:300", "search"
  
  # Dynamic action based on state
  has_stimulus_action "click", -> { draft? ? "saveDraft" : "publish" }
end
```

## Testing

### Testing Components with Stimulus Attrs

```ruby
class MyComponentTest < Minitest::Test
  def test_stimulus_controller_included
    component = MyComponent.new
    assert_includes component.dom_data[:controller], "my-component"
  end
  
  def test_conditional_controller
    component = MyComponent.new(active: true)
    assert_includes component.dom_data[:controller], "active-state"
    
    component = MyComponent.new(active: false)
    refute_includes component.dom_data[:controller], "active-state"
  end
  
  def test_stimulus_values
    component = MyComponent.new(user_id: 123)
    assert_equal "123", component.dom_data["my-component-user-id-value"]
  end
end
```

## Best Practices

### 1. Use Consistent Naming

```ruby
# Good: Consistent with Stimulus conventions
def self.controller_name
  "user-profile"  # kebab-case
end

# Avoid: Inconsistent naming
def self.controller_name
  "UserProfile"  # Wrong case
end
```

### 2. Keep Controllers Focused

```ruby
# Good: Single responsibility
class SearchComponent
  has_stimulus_controller "search"
  has_stimulus_action "input", "performSearch"
  has_stimulus_value "endpoint", "/search"
end

# Avoid: Too many responsibilities
class KitchenSinkComponent
  has_stimulus_controller "search"
  has_stimulus_controller "modal"
  has_stimulus_controller "dropdown"
  # ... many more
end
```

### 3. Use Procs for Dynamic Values

```ruby
# Good: Dynamic value using Proc
has_stimulus_value "timestamp", -> { Time.current.to_i }

# Avoid: Static value that should be dynamic
has_stimulus_value "timestamp", Time.current.to_i  # Set once at class load
```

### 4. Leverage Conditionals

```ruby
# Good: Conditional attributes for performance
has_stimulus_controller "animation", if: :animations_enabled?
has_stimulus_controller "analytics", unless: :private_mode?

# Avoid: Always including optional controllers
has_stimulus_controller "animation"  # Even when not needed
```

## Common Pitfalls

### 1. Forgetting controller_name

```ruby
# Wrong: No controller_name defined
class MyComponent
  include HasStimulusAttrs
  has_stimulus_controller  # Will raise NotImplementedError
end

# Correct: Define controller_name
class MyComponent
  include HasStimulusAttrs
  
  def self.controller_name
    "my-component"
  end
  
  has_stimulus_controller
end
```

### 2. Incorrect Proc Usage

```ruby
# Wrong: Proc called at class definition
has_stimulus_value "random", -> { rand(100) }.call

# Correct: Proc called at runtime
has_stimulus_value "random", -> { rand(100) }
```

### 3. Naming Conflicts

```ruby
# Be careful with multiple controllers
has_stimulus_target "button"  # For default controller
has_stimulus_target "button", controller: "modal"  # Different target!
```

## Performance Considerations

1. **Lazy Evaluation**: Procs are evaluated only when `dom_data` is called
2. **Caching**: Consider caching `dom_data` if called multiple times
3. **Conditional Attributes**: Use `:if`/`:unless` to avoid unnecessary attributes

```ruby
class OptimizedComponent
  include HasStimulusAttrs
  
  def dom_data
    @dom_data ||= super  # Cache the result
  end
  
  # Only include heavy controllers when needed
  has_stimulus_controller "rich-text-editor", if: :rich_text_enabled?
  has_stimulus_controller "syntax-highlighter", if: :code_blocks_present?
end
```

## Debugging Tips

### 1. Inspect Generated Attributes

```ruby
component = MyComponent.new
puts component.dom_data.inspect
# => {:controller=>"my-component", :action=>"click->my-component#handleClick", ...}
```

### 2. Check Formatted Output

```ruby
# In Rails console or tests
component = MyComponent.new
component.dom_data.each do |key, value|
  puts "data-#{key}=\"#{value}\""
end
```

### 3. Verify in Browser

Use browser developer tools to inspect the generated HTML and ensure Stimulus attributes are correct.

## Version History

- **0.2.2** (2025-01-31): Added support for Proc in `has_stimulus_action`
- **0.2.0** (2023-03-22): Added Proc support for controller option
- **0.1.0**: Initial release

## Contributing

The gem is open source and welcomes contributions. Key areas for contribution:
1. Additional stimulus attribute types
2. Performance improvements
3. Documentation and examples
4. Integration guides for different frameworks

## Conclusion

HasStimulusAttrs provides a powerful, Ruby-idiomatic way to manage Stimulus.js attributes in your components. By leveraging its DSL, you can write cleaner, more maintainable component code while ensuring proper Stimulus integration.
