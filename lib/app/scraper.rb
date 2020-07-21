#appelle nokogiri pour le scrapping
require 'nokogiri'
#appelle open uri nativement dans ruby pour ouvrir un URL
require 'open-uri'
require 'json'
require 'google_drive'
require 'csv'

class Scraper

    def get_townhall_email(townhall_url)
        email_html = townhall_url.xpath('//section[2]/div/table/tbody/tr[4]/td[2]') #l'adresse mail des mairies se trouvent sur ce xpath pour chaque url de mairie
        return email_html
    end

    def get_townhall_emails(townhalls_list)
    
        townhalls= townhalls_list.xpath('//a[contains(@href, "95")]') #on récupère la ligne html dont le href contient 95
        name_town = []
        names = []
        townhall_urls = []
    
        townhalls.each do |name|
            name_town << name.text #on récupère le texte de chacune de ces lignes dans name_town
        end
    
        for item in name_town #pour chaque entrée
            names << item.scan(/\w+/).map{|word| word.downcase}.join("-") #on scan tous les groupes de lettre on enlève les majuscules et on les lie avec "-"
        end
    
        for item in names
            townhall_urls << "https://www.annuaire-des-mairies.com/95/#{item}.html" #on crée chaque url de mairie en insérant le nom en minuscule lié dans la partie commune de l'url
        end

        townhalls_email_html = []
        townhalls_email = []

        for item in townhall_urls
            townhalls_email_html << get_townhall_email(Nokogiri::HTML(open("#{item}"))) #on récupère la ligne de chaque url de mairie où se trouve l'adresse mail
        end

        townhalls_email_html.each do |email|
            townhalls_email << email.text # on récupère le texte et donc l'adresse mail en string
        end

        townhall_email_hash = names.zip(townhalls_email).map{|k, v| {k => v}} #on hash nom de maire et email dans un array

        puts townhall_email_hash.sample(10)
        return townhall_email_hash

    end

    def save_as_JSON(townhall_email_hash)
        for item in townhall_email_hash
            File.write("./db/emails.json",townhall_email_hash.to_json)
        end
    end

    def save_as_spreadsheet(townhall_email_hash, spreadsheet_id)
        i=2
        session = GoogleDrive::Session.from_config("config.json")
        ws = session.spreadsheet_by_key("1T8Ohr_nxYe75nq2_BHJ982iTkmDd_3bn8Fwwyu7LPcc").worksheets[0]
        ws[1,1] = "Townhalls"
        ws[1,2] = "emails"
        ws.save
        for item in townhall_email_hash
            ws[i, 1] = item.first.first
            ws[i, 2] = item.first[1]
            i += 1
        end
        ws.save
    end

    def save_as_csv(townhall_email_hash)
        CSV.open("./db/emails.csv", "wb") do |csv|
            for item in townhall_email_hash
                csv << [item.first.first, item.first[1]]
            end
        end
    end

end

