module CUI
module EventLoop
  extend CUI::Events
  self.initialize # Events expects a call to initialize

  @running = true
  @exit = false
  @t_last_render = (Time.now.to_f * 1000).to_i
  @frames_per_second = 50
  @ms_per_frame = (1000 / @frames_per_second).to_i
  @windows = []
  @event_source = nil

  Curses.initscr
  Curses.raw # Don't generate signals, let the app handle all key presses.
  Curses.noecho
  Curses.start_color
  Curses.use_default_colors

  class << self
    attr_accessor :running,
      :t_last_render,
      :frames_per_second,
      :ms_per_frame,
      :event_window,
      :windows,
      :event_source

    def run
      # The window that events are retrieved from.
      # Recall that curses has a single event buffer for all windows.
      # Also, curses will refresh the window used to getch (drawing it on screen),
      # if it has been updated since last refreshed.
      # Using a separate window that we never write to prevents interruptions
      # in the normal render order.
      @event_window ||= CUI::Window.new

      # Draw the initial screen
      render

      loop {
        # Handle pending events (ERR, probably -1, just means no events yet).
        until (c = Curses.wgetch(@event_source.win || event_window.win)) == Curses::ERR
          if c == Curses::KEY_RESIZE
            Curses.refresh
          end
          event = KeyEvent.new(c)
          self.trigger(event)
          @event_source.trigger(event) if @event_source
          break if @exit
        end
        break if @exit

        ms_to_spare = ms_per_frame - ms_since_refresh
        if ms_to_spare <= 0
          render
        elsif ms_to_spare > 5
          # You got time, take a nap.
          # (TODO: Need a next_tick event to keep things awake)
          Curses.napms((ms_to_spare / 2).to_i)
        else
          # Snooze it, but wake up in time to refresh
          Curses.napms(ms_to_spare)
        end
      }
    rescue Exception => ex
      Curses.endwin
      $stderr.puts("(#{ex.class}) #{ex}")
      $stderr.puts(ex.backtrace.map {|l| "  #{l}" }.join("\n"))
    else
      Curses.endwin
    end

    def event_source=(val)
      @event_source = val || @event_window
      @event_source.focus
    end

    def exit
      @exit = true
    end

    def render
      self.trigger('render:start')
      event_source = nil
      @windows.each do |win|
        win.refresh unless win.equal? @event_source
      end
      # Make sure cursor is on event_source by refreshing last
      if @event_source
        @event_source.focus
        @event_source.refresh
      end

      Curses.doupdate
      @t_last_render = now
      self.trigger('render:end')
    end

    def ms_since_refresh
      now - @t_last_render
    end

    def now
      (Time.now.to_f * 1000).to_i
    end
  end
end
end
