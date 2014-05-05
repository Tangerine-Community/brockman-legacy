def timestamp
  Time.now.strftime("%Y %b %d %H:%M %Z")
end

def output (message, redirect = false)
  redirectHtml = "<meta http-equiv=\"refresh\" content=\"1;url=#{redirect}\">" if redirect
  return "<html><head>#{redirectHtml}<style>body { font-family: Helvetica; text-align:center; } h1 { font-size:200px; margin: 20px; color: rgba(0,0,0,0); text-shadow: 0 0 10px rgba(255,255,255,0.5), 0 12px 15px rgba(255,0,0,0.2), -6px -10px 15px rgba(0,255,0,0.2), 6px -10px 15px rgba(0,0,255,0.2); }</style></head><body><h1>#{message}</h1></body></html>"
end

def timeThis(description)

  tStart = Time.now.to_f
  print "#{description}..."
  yield
  tNow = Time.now.to_f
  puts "done. #{"%.3f" % (tNow - tStart)}"

end

def percentage(total, portion)

  return 0 if total == 0 or ! total.is_a? Fixnum
  return 0 if portion == 0 or ! portion.is_a? Fixnum

  return ((portion.to_f / total.to_f) * 100).to_i

end



