# frozen_string_literal: true

require_relative "has_stimulus_attrs/version"

require "has_dom_attrs"
require "stimulus_helpers"
require "active_support/core_ext/object/blank"

module HasStimulusAttrs
  include HasDomAttrs
  include StimulusHelpers

  def controller_name
    @_stimulus_controller_name ||= self.class.controller_name
  end

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def controller_name
      raise NotImplementedError
    end

    def has_stimulus_controller(name = controller_name, **options)
      key = :controller
      val = case name
            when Proc then instance_exec(&name)
            when Symbol then send(name)
            else name
      end

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_action(event, action, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = :action
      val = -> {
        a = case action
            when Proc then instance_exec(&action)
            else action.to_s
        end
        stimulus_action((controller || controller_name), event, a).values.first
      }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_class(name, value, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = -> { stimulus_class((controller || controller_name), name, "N/A").keys.first }
      val = -> {
        v = case value
            when Proc then instance_exec(&value)
            else value.to_s
        end
        stimulus_class((controller || controller_name), name, v).values.first
      }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_outlet(name, value, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = -> { stimulus_outlet((controller || controller_name), name, "N/A").keys.first }
      val = -> {
        v = case value
            when Proc then instance_exec(&value)
            when Symbol then send(value)
            else value
        end
        stimulus_outlet((controller || controller_name), name, v).values.first
      }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_param(name, value, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = -> { stimulus_param((controller || controller_name), name, "N/A").keys.first }
      val = -> {
        v = case value
            when Proc then instance_exec(&value)
            when Symbol then send(value)
            else value
        end
        stimulus_param((controller || controller_name), name, v).values.first
      }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_target(name, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = -> { stimulus_target((controller || controller_name), name).keys.first }
      val = -> { stimulus_target((controller || controller_name), name).values.first }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_value(name, value = nil, controller: nil, **options)
      controller = case controller
                   when Proc then instance_exec(&controller)
                   when Symbol then send(value)
                   else controller
      end

      key = -> { stimulus_value((controller || controller_name), name, "N/A").keys.first }
      val = -> {
        v = case value
            when Proc then instance_exec(&value)
            when Symbol then send(value)
            when NilClass then send(name)
            else value
        end
        stimulus_value((controller || controller_name), name, v).values.first
      }

      prepend___has_stimulus___method(key, val, **options)
    end

    private
      def prepend___has_stimulus___method(key, value, **options)
        # First, add the stimulus attribute module
        prepend(
          Module.new do
            define_method :dom_data do
              # Early exit for conditional attributes - avoid expensive key/value evaluation
              if options.key?(:if)
                cond = options[:if]
                cond_value = case cond
                             when Proc then instance_exec(&cond)
                             when Symbol, String then send(cond)
                             else cond
                end
                return super() unless cond_value
              end

              if options.key?(:unless)
                cond = options[:unless]
                cond_value = case cond
                             when Proc then instance_exec(&cond)
                             when Symbol, String then send(cond)
                             else cond
                end
                return super() if cond_value
              end

              # Only evaluate key and value if conditions pass
              k = case key
                  when Proc then instance_exec(&key)
                  else key
              end

              v = case value
                  when Proc then instance_exec(&value)
                  else value
              end

              super().tap do |data|
                data[k] = [data[k], v].reject(&:blank?).uniq.join(" ")
              end
            end
          end
        )

        # Then, ensure memoization is always at the top
        ensure_memoization_at_top
      end

      def ensure_memoization_at_top
        # Remove any existing memoization module
        if const_defined?(:StimulusMemoization, false)
          remove_const(:StimulusMemoization)
        end

        # Create a new memoization module at the top
        memoization_module = Module.new do
          def dom_data
            return @_stimulus_dom_data if defined?(@_stimulus_dom_data)
            @_stimulus_dom_data = super
          end

          def reset_dom_data_cache!
            remove_instance_variable(:@_stimulus_dom_data) if defined?(@_stimulus_dom_data)
            super if defined?(super)
          end
        end

        const_set(:StimulusMemoization, memoization_module)
        prepend(memoization_module)
      end
  end
end
