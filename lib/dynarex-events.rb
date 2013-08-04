#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'

class DynarexEvents < DynarexCron

  attr_reader :to_a

  def initialize(dynarex_file=nil, options={})
    
    opt = {sps_address: nil, drb_server: false}.merge options
    
    @cron_events  = []
    
    @dynarex_file = dynarex_file
    load_events()

    @sps_address = opt[:sps_address]
    
    if opt[:drb_server] == true then
      
      Thread.new {
        
        # start up the DRb service
        DRb.start_service 'druby://:57500', self

        # wait for the DRb service to finish before exiting
        DRb.thread.join    
      }
    end
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
    
    while @running == true
      iterate @cron_events
      sleep 60 # wait for 60 seconds
    end
  end  
  
  def to_a()
    
    @entries.inject([]) do |r,h| 

      h[:cron] = ChronicCron.new(h[:date]) 
      h[:job] = 'pub event: ' + h[:title]

      if h[:reminder].length > 0 then
        rmndr = {}
        rmndr[:cron] = ChronicCron.new((Chronic.parse(h[:date]) - ChronicDuration.parse(h[:reminder])).to_s)
        rmndr[:job] = 'pub event: reminder ' + h[:title]
        r << rmndr
      end

      r << h
    end
    
  end
end
