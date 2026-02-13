# frozen_string_literal: true

require "test_helper"
require "benchmark"

class PerformanceTestComponent
  include HasStimulusAttrs

  attr_accessor :expensive_call_count, :condition_value

  def initialize(condition_value: true)
    @expensive_call_count = 0
    @condition_value = condition_value
  end

  def self.controller_name
    "performance-test"
  end


  has_stimulus_controller
  has_stimulus_controller "conditional", if: :should_include_conditional?
  has_stimulus_action "click", "handleClick"
  has_stimulus_value "expensive", -> { expensive_computation }
  has_stimulus_value "conditional_expensive", -> { expensive_computation }, if: :should_include_conditional?

  private

  def expensive_computation
    @expensive_call_count += 1
    "expensive_result_#{@expensive_call_count}"
  end

  def should_include_conditional?
    @condition_value
  end
end

class HasStimulusAttrsPerformanceTest < Minitest::Test
  def test_dom_data_memoization
    component = PerformanceTestComponent.new

    # First call should compute and cache
    result1 = component.dom_data
    call_count_after_first = component.expensive_call_count

    # Second call should use cache, not call expensive method again
    result2 = component.dom_data
    call_count_after_second = component.expensive_call_count

    assert_equal result1, result2
    # The expensive method should be called the same number of times
    # (cached result should not trigger additional calls)
    assert_equal call_count_after_first, call_count_after_second
  end

  def test_cache_reset
    component = PerformanceTestComponent.new

    # First call
    component.dom_data
    first_call_count = component.expensive_call_count

    # Reset cache
    component.reset_dom_data_cache!

    # Second call should recompute
    component.dom_data
    second_call_count = component.expensive_call_count

    assert second_call_count > first_call_count
  end

  def test_conditional_attribute_early_exit
    # Component with condition = false should not evaluate expensive procs
    component = PerformanceTestComponent.new(condition_value: false)

    component.dom_data

    # Should have called expensive_computation once for non-conditional value
    # but NOT for conditional value (early exit)
    assert_equal 1, component.expensive_call_count

    # Verify conditional controller and value are not included
    refute_includes component.dom_data[:controller], "conditional"
    refute component.dom_data.key?("performance-test-conditional-expensive-value")
  end

  def test_conditional_attribute_inclusion
    # Component with condition = true should evaluate all procs
    component = PerformanceTestComponent.new(condition_value: true)

    component.dom_data

    # Should have called expensive_computation twice (once for each value)
    assert_equal 2, component.expensive_call_count

    # Verify conditional attributes are included
    assert_includes component.dom_data[:controller], "conditional"
    assert component.dom_data.key?("performance-test-conditional-expensive-value")
  end

  def test_controller_name_caching
    # Create a fresh class to test caching without interference
    test_class = Class.new do
      include HasStimulusAttrs

      @@call_count = 0

      def self.controller_name
        @@call_count += 1
        "cached-test"
      end

      def self.call_count
        @@call_count
      end
    end

    test_component = test_class.new

    # Multiple calls to controller_name should only call class method once
    name1 = test_component.controller_name
    name2 = test_component.controller_name
    name3 = test_component.controller_name

    assert_equal "cached-test", name1
    assert_equal name1, name2
    assert_equal name1, name3
    assert_equal 1, test_class.call_count
  end

  def test_performance_benchmark
    skip "Benchmark test - run manually for performance analysis" unless ENV["RUN_BENCHMARKS"]

    component = PerformanceTestComponent.new

    # Benchmark memoized vs non-memoized calls
    puts "\n=== Performance Benchmark ==="

    Benchmark.bm(20) do |x|
      x.report("First call (compute):") do
        1000.times { component.reset_dom_data_cache!; component.dom_data }
      end

      x.report("Cached calls:") do
        component.reset_dom_data_cache!
        component.dom_data # Prime cache
        1000.times { component.dom_data }
      end
    end
  end
end
