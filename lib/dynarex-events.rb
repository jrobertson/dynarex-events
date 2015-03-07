#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'


class DynarexEvents < DynarexCron

  attr_reader :to_a

  def initialize(dynarex_file=nil, options={})
    
    opt = {sps_address: nil, time_offset: 0}.merge options
    
    @time_offset = opt[:time_offset]
    @cron_events  = []
    
    @dynarex_file = dynarex_file
    load_events()

    @sps_address = opt[:sps_address]
    
  end    

  def load_events()
    
    dynarex = Dynarex.new @dynarex_file
    @entries = dynarex.to_h
    @cron_events = self.to_a
  end  
  
  alias refresh load_events
  
  def start

    @running = true
    puts '[' + Time.now.strftime(DF) + '] DynarexEvents started'
    params = {uri: "ws://%s:%s" % [@sps_address, @sps_port]}    

    RunEvery.new(seconds: 60) { iterate @cron_events }
    
  end  
  
  def to_a()
    
    @entries.inject([]) do |r,h| 

      time = Time.now + @time_offset
      h[:cron] = ChronicCron.new(h[:date], time) 
      h[:fqm] = 'event: ' + h[:title]

      if h[:reminder].length > 0 then
        rmndr = {}
        rmndr[:cron] = ChronicCron.new((Chronic.parse(h[:date]) - 
                              ChronicDuration.parse(h[:reminder])).to_s, time)
        rmndr[:fqm] = 'event: reminder ' + h[:title]
        r << rmndr
      end

      r << h
    end
    
  end
end
