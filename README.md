# Introducing the Dynarex-events gem

    require 'dynarex-events'

    s =<<EOF
    <?dynarex schema="entries[title,tags]/entry(date,title,reminder,recurring)"?>
    title: Future events
    tags: events calendar dates appointments schedule
    --+

    date: 25-Nov@0930
    title: building1
    reminder:
    recurring: every 2 weeks

    date: 25-Nov@2240
    title: testing5
    reminder: 1 hour before

    date: 25-Nov@0930
    title: Meeting with Christine in building 44

    date: 25-Nov@1000
    title: check widget x102

    date: 25-Nov@1936
    title: Meeting with Julie (not real name) at Cafe X

    date: 26-Nov@0600
    title: Walking up the Pentland Hills 
    EOF

    d = Dynarex.new
    d.import(s)
    de = DynarexEvents.new(d, sps_address: '192.168.4.170', sps_port: '59000') 
    de.start

The above example runs a scheduler with the dates provided, and when the time or reminder time matches the current time then an event message is published to the SimplePubSub broker. If the time was now 7:36pm on the 25th Nov the topic 'event' with the message 'Meeting with Julie (not real name) at Cafe X' would be published.

Note: It is expected the reminder should be set as a duration countdown rather than a date (e.g. 1 hour before).

## Resources

* [jrobertson/dynarex-events](https://github.com/jrobertson/dynarex-events)

gem dynarexevents simplepubsub cron
