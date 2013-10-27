#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'

class DynarexEvents < DynarexCron

  attr_reader :to_a

  # options: e.g. sps_address, 'sps', drb_server: 58000
  #
  def initialize(dynarex_file=nil, options={})
    
    opt = {sps_address: nil, drb_server: nil}.merge options
    
    @entries, @other_entries, @cron_events  = [], [], []

    @dynarex_file = dynarex_file
    load_events()

    @sps_address = opt[:sps_address]
    
    if opt[:drb_server] then

      Thread.new {
        
        # start up the DRb service
        DRb.start_service 'druby://:' + opt[:drb_server], self

        # wait for the DRb service to finish before exiting
        DRb.thread.join    
      }
    end
  end    

  def add_entry(h)
    # if the entry already exists delete it
    @other_entries.delete @other_entries.find {|x| x[:job] == h[:job]}
    @other_entries << h
  end

  def load_events()
    
    dynarex = Dynarex.new @dynarex_file
    @entries = (dynarex.to_h || []) + @other_entries

    @cron_events = self.to_a if @entries
    'events loaded and refreshed'
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

    return unless @entries

    @entries.inject([]) do |r,h| 

      s = h[:expression].to_s.length > 0 ? h[:expression] : 
        h[:date] + ' ' + h[:recurring].to_s 

      h[:cron] = ChronicCron.new(s) 
      h[:job] ||= 'pub event: ' + h[:title]

      if h[:reminder].to_s.length > 0 then
        rmndr = {}
        rmndr[:cron] = ChronicCron.new((Chronic.parse(h[:date]) - ChronicDuration.parse(h[:reminder])).to_s)
        rmndr[:job] = 'pub event: reminder ' + h[:title]
        r << rmndr
      end

      r << h
    end
    
  end
end