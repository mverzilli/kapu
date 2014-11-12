require 'open-uri'
require 'pdf-reader'
require 'pry'
require 'curb'
require 'rest-client'
require 'configatron'

load 'config.rb'

def send_simple_message(report)
  RestClient.post configatron.mailgun_endpoint,
  :from => configatron.from,
  :to => configatron.to,
  :subject => "Reporte de mareas Puerto San Fernando",
  :text => report
end

def parse(where, what)
  if where.start_with?(what)
    where
  else
    nil
  end
end

forecast = open 'http://www.hidro.gov.ar/oceanografia/pronostico/pronostico.pdf'
reader = PDF::Reader.new forecast

body = reader.pages.first.text.split("\n").map{|l| l.strip }

date = nil
validity = nil
san_fernando = nil
san_fernando_line = nil
puerto_sf = nil

body.each_with_index do |l, i|
  date ||= parse(l, "FECHA")
  validity ||= parse(l, "VALIDO")

  try_san_fernando = parse(l, "SAN FERNANDO")

  if try_san_fernando
    san_fernando = try_san_fernando
    san_fernando_line = i - 2
  end  
end

puerto_sf = body[san_fernando_line] if san_fernando_line

if san_fernando
  report = "#{date}\n#{validity}\n#{puerto_sf}\n#{san_fernando}"
  send_simple_message report
end




    