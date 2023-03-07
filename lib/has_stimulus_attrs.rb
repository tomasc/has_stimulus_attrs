# frozen_string_literal: true

require_relative "has_stimulus_attrs/version"

module HasStimulusAttrs
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def has_stimulus_controller(name = controller_name, **options)
      key = :controller
      val = name

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_action(event, action, controller: nil, **options)
      key = :action
      val = -> { stimulus_action((controller || controller_name), event, action).values.first }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_actions(**options)
      controller = options[:controller] || controller_name
      actions = options.except(:controller, :if, :unless)
      key = :action
      val = -> { stimulus_actions(controller, actions).values.first }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_class(name, value, controller: nil, **options)
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

    def has_stimulus_classes(**options)
      classes = options.except(:controller, :if, :unless)
      classes.each do |name, value|
        has_stimulus_class(name, value, controller: options[:controller], **options.except(:controller))
      end
    end

    def has_stimulus_outlet(name, value, controller: nil, **options)
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

    def has_stimulus_outlets(**options)
      outlets = options.except(:controller, :if, :unless)
      outlets.each do |name, value|
        has_stimulus_outlet(name, value, controller: options[:controller], **options)
      end
    end

    def has_stimulus_param(name, value, controller: nil, **options)
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

    def has_stimulus_params(**options)
      params = options.except(:controller, :if, :unless)
      params.each do |name, value|
        has_stimulus_param(name, value, controller: options[:controller], **options)
      end
    end

    def has_stimulus_target(name, controller: nil, **options)
      key = -> { stimulus_target((controller || controller_name), name).keys.first }
      val = -> { stimulus_target((controller || controller_name), name).values.first }

      prepend___has_stimulus___method(key, val, **options)
    end

    def has_stimulus_value(name, value = nil, controller: nil, **options)
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

    def has_stimulus_values(**options)
      values = options.except(:controller, :if, :unless)
      values.each do |name, value|
        has_stimulus_value(name, value, controller: options[:controller], **options)
      end
    end

    private

    def prepend___has_stimulus___method(key, value, **options)
      prepend(
        Module.new do
          define_method :dom_data do
            cond = options[:if] || options[:unless]
            cond_value = case cond
                          when Proc then instance_exec(&cond)
                          when Symbol, String then send(cond)
            end

            if cond && options.key?(:if)
              return super() unless cond_value
            end

            if cond && options.key?(:unless)
              return super() if cond_value
            end

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
    end
  end
end
