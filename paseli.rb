# coding: UTf-8

require 'mechanize'

class Mechanize::Util
  class << self
    alias :__encode_to__ :encode_to

    def encode_to(encoding, str)
      encoding = "Shift_JIS" if encoding == "shift-jis"
      __encode_to__(encoding, str)
    end
  end
end

class PASELI
  class LoginFailiureError < StandardError; end
  class NotLoggedInError < StandardError; end

  class PASELI::Entry
    def initialize(date:, name:, amount:)
      @date = date
      if (match = name.match(/\((.*)\)/))
        @name = match[1]
      else
        @name = name
      end
      @amount = amount
    end

    def name
      # return "REFLEC BEAT groovin'!!" if @name == "REFLEC BEAT colette" && @date > Date.new(2014, 6, 5)
      return @name
    end

    attr_reader :date, :amount
  end

  def initialize(konami_id:, password:)
    @agent = Mechanize.new
    @logged_in = false

    login(konami_id: konami_id, password: password) if (konami_id && password)
  end

  def login(konami_id:, password:)
    # login via e-AMUSEMENT

    STDERR.print 'Logging in via eAMUSEMENT... '
    login_page = @agent.get('https://p.eagate.573.jp/gate/p/login.html')
    form = login_page.forms.first
    form.field_with(:name => 'KID').value = konami_id
    form.field_with(:name => 'pass').value = password
    mypage = form.submit
    raise LoginFailiureError "Login failed: Invalid KONAMI ID or password" if !mypage.uri.to_s.include?('mypage')

    STDERR.puts 'Success.'
    @my_konami_logged_in = true
  end

  def paseli_history
    raise NotLoggedInError if !@my_konami_logged_in

    STDERR.puts 'Obtaining PASELI history... '
    eamusement_tab = @agent.get('http://p.eagate.573.jp/gate/p/eamusement/index.html')
    paseli_page = eamusement_tab.links.select { |link| link.href.start_with?('https://p.eagate.573.jp/payment/to_mykonami.html') }.first.click
    paseli_history = paseli_page.links.select { |link| link.href == 'payinfo.kc' }.first.click

    STDERR.print 'Obtaining # of pages... '
    page_count = paseli_history.links.select { |link| link.href =~ /javascript:goPage\(\d\)/ }.length + 1
    STDERR.puts "#{page_count}"

    entries = Array.new

    page_count.times.with_index do |i|
      STDERR.puts "Processing page #{i + 1}..."

      page = @agent.post('https://my.konami.net/paseli/payinfo.kc', { "strSub" => "", "strPage" => (i+1).to_s })
      page.search('.buy_table tr:nth-of-type(n+3)').each do |payment|
        entries.push(PASELI::Entry.new(
          date: Date.parse(payment.search("td:nth-child(1)").text),
          name: payment.search("td:nth-child(2)").text,
          amount: payment.search("td:nth-child(3)").text.gsub(/[^\d]/, '').to_i
          # puts "Date: #{payment.search("td:nth-child(3)").text}"
        ))
      end
    end

    return entries.reverse
  end
end
