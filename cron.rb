#! /usr/bin/env ruby

#
# This file is to be run via crontab
#

#
# What is cached
# Three requests
# 1. spritRotut by tripId
# 2. tutorTrips by year+month
# 3. tutorTrips by workflowId
# The union of the latter two will give a list of 

require_relative 'config.rb'
require_relative 'helpers/Couch'
require_relative 'helpers/CouchIterator'


header = <<END

Brockman presents
               |                       ,---.               |    
,---.,---.,---.|---.,---.    ,---.,---.|__. ,---.,---.,---.|---.
|    ,---||    |   ||---'    |    |---'|    |    |---'`---.|   |
`---'`---^`---'`   '`---'    `    `---'`    `    `---'`---'`   '
END

puts header

dbs = [ 'tangent_data_1m_baringo', 'group-national_tablet_program' ]
years  = [ 2013, 2014, 2015 ]
months = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ]
workflowIds = ["00b0a09a-2a9f-baca-2acb-c6264d4247cb","c835fc38-de99-d064-59d3-e772ccefcf7d"]

CHUNK_SIZE = 1000

dbs.each { |db|

  puts "db: #{db}"

  couch = Couch.new({
    :host      => $settings[:host],
    :login     => $settings[:login],
    :designDoc => $settings[:designDoc],
    :db        => db
  })

  puts "Caching trips: "

  workflowIds.each { |workflowId|
    tripsRequest = JSON.parse(couch.postRequest({
      :view => "tutorTrips",
      :params => {"reduce" => false},
      :data => {"keys" => ["workflow-#{workflowId}"]}
    }))
    puts "Processing Workflow: #{workflowId}"
    hTripIds = {}
    tripsRequest['rows'].each { |row| hTripIds[row['value']] = true}
    aTripIds = hTripIds.keys
    totalTripIds = aTripIds.length
   
    

    (0..totalTripIds).step(CHUNK_SIZE).each { | chunkIndex |
      idChunk = aTripIds.slice(chunkIndex, chunkIndex + CHUNK_SIZE)
      couch.postRequest({
        :view   => "spirtRotut",
        :params => { "group" => true },
        :cache  => true,
        :data   => { "keys" => idChunk }
      })
      print "M"
    }

  }

  
  puts "view: tutorTrips"

  years.each { |year| 

    puts "year: #{year}"

    print "month: "
    months.each { |month|

      print "#{month} "

      monthKeys = ["year#{year}month#{month}"]
      response = couch.postRequest({ 
        :view   => "tutorTrips", 
        :data   => { "keys"   => monthKeys }, 
        :params => { "reduce" => false }, 
        :categoryCache => true
      } )

    } 
    print "\n"
  }


  print "workflowId:"
  workflowIds.each { |workflowId|
    print "#{workflowId} "
    response = couch.postRequest({ 
      :view => "tutorTrips", 
      :data => { "keys" => ["workflow-#{workflowId}"] }, 
      :params => { "reduce" => false },
      :categoryCache => true
    } )
  }

}


