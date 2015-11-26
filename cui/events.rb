module CUI
module Events

  module All
    def self.===(anything)
      true
    end
  end

  def initialize
    @event_listeners = Hash.new { |h, k| h[k] = [] }
  end

  def trigger(event)
    @event_listeners.keys.each do |event_type|
      if event_type === event
        @event_listeners[event_type].each do |listener|
          listener[event]
        end
      end
    end
  end

  def on(event_type, &block)
    raise ArgumentError.new("on called without a block") unless block_given?
    @event_listeners[event_type].push(block) unless @event_listeners[event_type].include?(block)
  end

  def once(event_type, &block)
    raise ArgumentError.new("once called without a block") unless block_given?
    wrapper = proc { |*args|
      block[*args]
      self.off(event_type, &wrapper)
    }
    self.on(event_type, &wrapper)
  end

  def off(event_type, &block)
    raise ArgumentError.new("off called without a block") unless block_given?
    @event_listeners.keys.each do |et|
      if et == event_type
        @event_listeners[et].delete(block)
      end
    end
  end
end

extend Events
initialize
end
