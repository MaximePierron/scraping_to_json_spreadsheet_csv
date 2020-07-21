require_relative '../lib/mairie_christmas'

describe "the email_html method" do
    it "does not return a nil " do
        address = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/95/ableiges.html"))
        expect(get_townhall_emails(address)).not_to be_nil
    end
end

describe "the townhall_emails method" do
    it "does not return a nil " do
        address = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
        expect(get_townhall_emails(address)).not_to be_nil
    end
    it "must be an array of reasonable size" do
        address = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
        expect(get_townhall_emails(address).length).to be >50
        expect(get_townhall_emails(address).length).to be <200
    end
    it "must be an array that contains a city name entry and the email address to be a string" do
        address = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
        expect(get_townhall_emails(address).any? {|h| h.first[0].include?("la-roche-guyon") && h.first[1].is_a?(String) }).to be true
    end

    it "must return hashes value shapes as email address" do
        address = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
        expect(get_townhall_emails(address).any? {|h| h.first[1].include?("@") }).to be true
    end
end