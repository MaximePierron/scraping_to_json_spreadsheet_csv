require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib/app/", __FILE__)
require 'scraper'

puts "\nNous allons scraper les mairies du Val d'Oise.\n"
scrap = Scraper.new
spreadsheet_id = "1T8Ohr_nxYe75nq2_BHJ982iTkmDd_3bn8Fwwyu7LPcc"
townhalls_list = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
townhalls_hash = scrap.get_townhall_emails(townhalls_list)
puts "\nNous allons d'abord les enregistrer en .json\n"
scrap.save_as_JSON(townhall_email_hash)
puts "\nPuis dans un Google spreadsheet\n"
scrap.save_as_spreadsheet(townhalls_hash, spreadsheet_id)
puts "\nEt maintenant en .csv\n"
scrap.save_as_csv(townhalls_hash)
puts "\nAll done !\n"