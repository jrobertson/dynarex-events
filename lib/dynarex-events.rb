#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'

class DynarexEvents  < DynarexCron

  def initialize(dynarex_file, sps_address=nil)

    dynarex = Dynarex.new dynarex_file
    entries = dynarex.to_h

    @cron_entries = entries.inject([]) do |r,h| 

      h[:cron] = ChronicCron.new(h[:date]) 
      h[:job] = 'pub event: ' + h[:title]

      if h[:reminder].length > 0 then
        rmndr = {}
        rmndr[:cron] = Chronic.parse(h[:date]) - ChronicDuration.parse(h[:reminder])
        rmndr[:job] = 'pub event: reminder ' + h[:title]
        r << rmndr
      end

      r << h
    end
    @sps_address = sps_address
  end
end
