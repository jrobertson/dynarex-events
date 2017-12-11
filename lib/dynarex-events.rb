#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'


class DynarexEvents < DynarexCron

  attr_reader :to_a

  def initialize(dxfile=nil, sps_address: 'sps', sps_port: '59000',  \
      log: nil, time_offset: 0)
    
    super(dxfile, sps_address: sps_address, sps_port: sps_port,  \
      log: log, time_offset: time_offset, logtopic: 'DynarexEvents')

  end    

  def load_entries(dx)
    
    @entries = dx.to_h
    @cron_entries = self.to_a

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
        rmndr[:fqm] = 'event/reminder: ' + h[:title]
        r << rmndr
      end

      r << h
    end
    
  end
end