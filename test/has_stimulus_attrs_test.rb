# frozen_string_literal: true

require "test_helper"

class Component
  include HasStimulusAttrs

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
  has_stimulus_controller -> { "proc--controller" }
  has_stimulus_controller -> { instance_method_controller }
  has_stimulus_controller "other--controller"
  has_stimulus_controller "if--controller", if: :if?
  has_stimulus_controller "unless--controller", unless: :unless?

  has_stimulus_action "click", "onClick"
  has_stimulus_action "click", "onClick", controller: "other--controller"
  has_stimulus_action "click", "onClick", controller: -> { "proc--controller" }

  has_stimulus_class "class_name", "component_class_name"
  has_stimulus_class "class_name", "component_class_name", controller: -> { "proc--controller" }
  has_stimulus_class "proc_class_name", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_class "sym_class_name", :other_class_name, controller: "other--controller"

  has_stimulus_outlet "outlet", ".selector"
  has_stimulus_outlet "outlet", ".selector", controller: -> { "proc--controller" }
  has_stimulus_outlet "proc_outlet", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_outlet "sym_outlet", :dynamic_value, controller: "other--controller"

  has_stimulus_param "param", "param_value"
  has_stimulus_param "param", "param_value", controller: -> { "proc--controller" }
  has_stimulus_param "proc_param", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_param "sym_param", :dynamic_value, controller: "other--controller"

  has_stimulus_target "target"
  has_stimulus_target "target", controller: "other--controller"
  has_stimulus_target "target", controller: -> { "proc--controller" }

  has_stimulus_value "value", "value_value"
  has_stimulus_value "value", "value_value", controller: -> { "proc--controller" }
  has_stimulus_value "proc_value", -> { dynamic_value }, controller: "other--controller"
  has_stimulus_value "sym_value", :dynamic_value, controller: "other--controller"

  def if?
    true
  end

  def unless?
    true
  end

  def instance_method_controller
    "instance-method-controller"
  end
end

class HasStimulusAttrsTest < Minitest::Test
  def test_has_stimulus_controller
    component = Component.new
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "component-controller"
    assert_includes dom_data[:controller], "proc--controller"
    assert_includes dom_data[:controller], "instance-method-controller"
    assert_includes dom_data[:controller], "other--controller"
    assert_includes dom_data[:controller], "if--controller"
    refute_includes dom_data[:controller], "unless--controller"
  end

  def test_has_stimulus_action
    component = Component.new
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_includes dom_data[:action], "click->component-controller#onClick"
    assert_includes dom_data[:action], "click->other--controller#onClick"
  end

  def test_has_stimulus_class
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_equal "component_class_name", dom_data["component-controller-class-name-class"]
    assert_equal "foo", dom_data["other--controller-proc-class-name-class"]
    assert_equal "other_class_name", dom_data["other--controller-sym-class-name-class"]
  end

  def test_has_stimulus_outlet
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_equal ".selector", dom_data["component-controller-outlet-outlet"]
    assert_equal "foo", dom_data["other--controller-proc-outlet-outlet"]
    assert_equal "foo", dom_data["other--controller-sym-outlet-outlet"]
  end

  def test_has_stimulus_param
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_equal "param_value", dom_data["component-controller-param-param"]
    assert_equal "foo", dom_data["other--controller-proc-param-param"]
    assert_equal "foo", dom_data["other--controller-sym-param-param"]
  end

  def test_has_stimulus_target
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_equal "target", dom_data["component-controller-target"]
    assert_equal "target", dom_data["other--controller-target"]
  end

  def test_has_stimulus_value
    component = Component.new(dynamic_value: "foo")
    dom_data = component.send(:dom_data)

    assert_includes dom_data[:controller], "proc--controller"
    assert_equal "value_value", dom_data["component-controller-value-value"]
    assert_equal "foo", dom_data["other--controller-proc-value-value"]
    assert_equal "foo", dom_data["other--controller-sym-value-value"]
  end
end
