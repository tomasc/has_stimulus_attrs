require "test_helper"
require "has_dom_attrs"
require "stimulus_helpers"

class Component
  include HasDomAttrs
  include HasStimulusAttrs
  include StimulusHelpers

  attr_accessor :dynamic_value

  def initialize(dynamic_value: "")
    @dynamic_value = dynamic_value
  end

  def self.controller_name
    "component-controller"
  end

  def controller_name
    self.class.controller_name
  end

  has_stimulus_controller
  has_stimulus_controller "other--controller"
  has_stimulus_controller "if--controller", if: :if?
  has_stimulus_controller "unless--controller", unless: :unless?

  has_stimulus_action "click", "onClick"
  has_stimulus_action "click", "onClick", controller: "other--controller"
  has_stimulus_actions open: "onOpen", close: "onClose"

  has_stimulus_class "class_name", "component_class_name"
  has_stimulus_class "proc_class_name", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_class "sym_class_name", :other_class_name, controller: "other--controller"
  has_stimulus_classes open: "component--open", closed: -> { dynamic_value }
  has_stimulus_classes success: "other--success", error: -> { "other--#{dynamic_value}" }, controller: "other--controller"

  has_stimulus_outlet "outlet", ".selector"
  has_stimulus_outlet "proc_outlet", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_outlet "sym_outlet", :dynamic_value, controller: "other--controller"
  has_stimulus_outlets outlet_a: ".component__outlet_a", outlet_b: ".component__outlet_b"
  has_stimulus_outlets other_outlet_a: ".other__outlet_a", other_outlet_b: ".other__outlet_b", controller: "other--controller"

  has_stimulus_param "param", "param_value"
  has_stimulus_param "proc_param", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_param "sym_param", :dynamic_value, controller: "other--controller"
  has_stimulus_params a: "b", b: "a", dynamic: -> { dynamic_value }
  has_stimulus_params other_a: "b", other_b: "a", other_dynamic: -> { dynamic_value }, controller: "other--controller"

  has_stimulus_target "target"
  has_stimulus_target "target", controller: "other--controller"

  has_stimulus_value "value", "value_value"
  has_stimulus_value "proc_value", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_value "sym_value", :dynamic_value, controller: "other--controller"
  has_stimulus_values a: "b", b: "a", dynamic: :dynamic_value
  has_stimulus_values other_a: "b", other_b: "a", other_dynamic: -> { dynamic_value }, controller: "other--controller"

  def if?
    true
  end

  def unless?
    true
  end
end

class HasStimulusAttrsTest < Minitest::Test
  def test_has_stimulus_controller
    component = Component.new
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "component-controller"
    assert_includes dom_data[:controller], "other--controller"
    assert_includes dom_data[:controller], "if--controller"
    refute_includes dom_data[:controller], "unless--controller"
  end

  def test_has_stimulus_action
    component = Component.new
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:action], "click->component-controller#onClick"
    assert_includes dom_data[:action], "click->other--controller#onClick"
    assert_includes dom_data[:action], "open->component-controller#onOpen"
    assert_includes dom_data[:action], "close->component-controller#onClose"
  end

  def test_has_stimulus_class
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_equal "component_class_name", dom_data["component-controller-class-name-class"]
    assert_equal "foo", dom_data["other--controller-proc-class-name-class"]
    assert_equal "other_class_name", dom_data["other--controller-sym-class-name-class"]
    assert_equal "component--open", dom_data["component-controller-open-class"]
    assert_equal "foo", dom_data["component-controller-closed-class"]
    assert_equal "other--success", dom_data["other--controller-success-class"]
    assert_equal "other--foo", dom_data["other--controller-error-class"]
  end

  def test_has_stimulus_outlet
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_equal ".selector", dom_data["component-controller-outlet-outlet"]
    assert_equal "foo", dom_data["other--controller-proc-outlet-outlet"]
    assert_equal "foo", dom_data["other--controller-sym-outlet-outlet"]
    assert_equal ".component__outlet_a", dom_data["component-controller-outlet-a-outlet"]
    assert_equal ".component__outlet_b", dom_data["component-controller-outlet-b-outlet"]
    assert_equal ".other__outlet_a", dom_data["other--controller-other-outlet-a-outlet"]
    assert_equal ".other__outlet_b", dom_data["other--controller-other-outlet-b-outlet"]
  end

  def test_has_stimulus_param
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_equal "param_value", dom_data["component-controller-param-param"]
    assert_equal "foo", dom_data["other--controller-proc-param-param"]
    assert_equal "foo", dom_data["other--controller-sym-param-param"]
    assert_equal "b", dom_data["component-controller-a-param"]
    assert_equal "a", dom_data["component-controller-b-param"]
    assert_equal "foo", dom_data["component-controller-dynamic-param"]
    assert_equal "b", dom_data["other--controller-other-a-param"]
    assert_equal "a", dom_data["other--controller-other-b-param"]
    assert_equal "foo", dom_data["other--controller-other-dynamic-param"]
  end

  def test_has_stimulus_target
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_equal "target", dom_data["component-controller-target"]
    assert_equal "target", dom_data["other--controller-target"]
  end

  def test_has_stimulus_value
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_equal "value_value", dom_data["component-controller-value-value"]
    assert_equal "foo", dom_data["other--controller-proc-value-value"]
    assert_equal "foo", dom_data["other--controller-sym-value-value"]
    assert_equal "b", dom_data["component-controller-a-value"]
    assert_equal "a", dom_data["component-controller-b-value"]
    assert_equal "foo", dom_data["component-controller-dynamic-value"]
    assert_equal "b", dom_data["other--controller-other-a-value"]
    assert_equal "a", dom_data["other--controller-other-b-value"]
    assert_equal "foo", dom_data["other--controller-other-dynamic-value"]
  end
end
