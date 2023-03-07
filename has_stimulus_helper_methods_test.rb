# frozen_string_literal: true

require "test_helper"
require "modulor/component"

module Modulor
  class Component
    class HasStimulusHelperMethodsTest < ActiveSupport::TestCase
      class ComponentClass < Modulor::Component
        option :dynamic_value, type: Types::String

        has_stimulus_controller
        has_stimulus_controller "other--controller"
        has_stimulus_controller "if--controller", if: :if?
        has_stimulus_controller "unless--controller", unless: :unless?

        has_stimulus_action "click", "onClick"
        has_stimulus_action "click", "onClick", controller: "other--controller"

        has_stimulus_class "class_name"
        has_stimulus_class "proc_class_name", -> { dynamic_value }, controller: "other--controller"
        has_stimulus_class "sym_class_name", :other_class_name, controller: "other--controller"

        has_stimulus_outlet "outlet", ".selector"
        has_stimulus_outlet "proc_outlet", -> { dynamic_value }, controller: "other--controller"
        has_stimulus_outlet "sym_outlet", :dynamic_value, controller: "other--controller"

        has_stimulus_param "param", "param_value"
        has_stimulus_param "proc_param", -> { dynamic_value }, controller: "other--controller"
        has_stimulus_param "sym_param", :dynamic_value, controller: "other--controller"

        has_stimulus_target "target"
        has_stimulus_target "target", controller: "other--controller"

        has_stimulus_value "value", "value_value"
        has_stimulus_value "proc_value", -> { dynamic_value }, controller: "other--controller"
        has_stimulus_value "sym_value", :dynamic_value, controller: "other--controller"

        def if?
          true
        end

        def unless?
          true
        end

        def styles
          OpenStruct.new(class_name: ".class_name", other_class_name: ".other_class_name")
        end
      end

      let(:component) { ComponentClass.new(dynamic_value: Faker::Name.name) }

      describe "has_stimulus_controller" do
        it { _(component.send(:dom_data)[:controller]).must_include ComponentClass.controller_name }
        it { _(component.send(:dom_data)[:controller]).must_include "other--controller" }
        it { _(component.send(:dom_data)[:controller]).must_include "if--controller" }
        it { _(component.send(:dom_data)[:controller]).wont_include "unless--controller" }
      end

      describe "has_stimulus_action" do
        it { _(component.send(:dom_data)[:action]).must_include "click->#{ComponentClass.controller_name}#onClick" }
        it { _(component.send(:dom_data)[:action]).must_include "click->other--controller#onClick" }
      end

      describe "has_stimulus_class" do
        it { _(component.send(:dom_data)["#{ComponentClass.controller_name}-class-name-class"]).must_equal component.styles.class_name }
        it { _(component.send(:dom_data)["other--controller-proc-class-name-class"]).must_equal component.dynamic_value }
        it { _(component.send(:dom_data)["other--controller-sym-class-name-class"]).must_equal component.styles.other_class_name }
      end

      describe "has_stimulus_outlet" do
        it { _(component.send(:dom_data)["#{ComponentClass.controller_name}-outlet-outlet"]).must_equal ".selector" }
        it { _(component.send(:dom_data)["other--controller-proc-outlet-outlet"]).must_equal component.dynamic_value }
        it { _(component.send(:dom_data)["other--controller-sym-outlet-outlet"]).must_equal component.dynamic_value }
      end

      describe "has_stimulus_param" do
        it { _(component.send(:dom_data)["#{ComponentClass.controller_name}-param-param"]).must_equal "param_value" }
        it { _(component.send(:dom_data)["other--controller-proc-param-param"]).must_equal component.dynamic_value }
        it { _(component.send(:dom_data)["other--controller-sym-param-param"]).must_equal component.dynamic_value }
      end

      describe "has_stimulus_target" do
        it { _(component.send(:dom_data)["#{ComponentClass.controller_name}-target"]).must_equal "target" }
        it { _(component.send(:dom_data)["other--controller-target"]).must_equal "target" }
      end

      describe "has_stimulus_value" do
        it { _(component.send(:dom_data)["#{ComponentClass.controller_name}-value-value"]).must_equal "value_value" }
        it { _(component.send(:dom_data)["other--controller-proc-value-value"]).must_equal component.dynamic_value }
        it { _(component.send(:dom_data)["other--controller-sym-value-value"]).must_equal component.dynamic_value }
      end
    end
  end
end
