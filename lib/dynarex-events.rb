#!/usr/bin/env ruby

# file: dynarex-events.rb

require 'chronic_duration'
require 'dynarex_cron'


class DynarexEvents < DynarexCron

  attr_reader :to_a

  # options: e.g. sps_address: 'sps', drb_port: 58000
  #
  def initialize(dynarex_file=nil, options={})
    
    opt = {sps_address: nil, sps_port: '59000', drb_port: nil}.merge options

    @logger = Logger.new(opt[:log],'weekly') if opt[:log]    
    @entries, @other_entries, @cron_events  = [], [], []

    @dynarex = dynarex_file
    load_events()

    @sps_address, @sps_port = opt[:sps_address], opt[:sps_port]
    
    if opt[:drb_port] then

      Thread.new {
        
        # start up the DRb service
        DRb.start_service 'druby://:' + opt[:drb_port], self

        # wait for the DRb service to finish before exiting
        DRb.thread.join    
      }
    end
  end    

  def add_entry(h)
    # if the entry already exists delete it
    @other_entries.delete @other_entries.find {|x| x[:job] == h[:job]}
    @other_entries << h
    self.refresh
    'updated and refreshed'
  end

  def load_events()
    
    dynarex = @dynarex.is_a?(Dynarex) ? @dynarex : Dynarex.new(@dynarex)
    @entries = (dynarex.to_h || []) + @other_entries

    @cron_events = self.to_a if @entries
    'events loaded and refreshed'
  end  
  
  alias refresh load_events
  
  def start

    @running = true
    puts '[' + Time.now.strftime(DF) + '] DynarexEvents started'
    params = {uri: "ws://%s:%s" % [@sps_address, @sps_port]}    

    c = WebSocket::EventMachine::Client
    @ws = nil

    EventMachine.run do

      @ws = c.connect(params)

      EM.add_periodic_timer(60) do
        iterate @cron_events
      end

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