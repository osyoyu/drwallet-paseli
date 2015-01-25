# coding: UTF-8

require 'mechanize'
require 'JSON'

class DrWallet
  class LoginFailiureError < StandardError; end
  class NotLoggedInError < StandardError; end

  # 口座 (not アカウント)
  class DrWallet::Account
    def initialize(id, name)
      @id = id
      @name = name
    end

  end

  class DrWallet::Category
    def initialize(id, name)
      @id = id
      @name = name
    end

    attr_reader :id, :name
  end

  class DrWallet::Receipt
    def initialize(id:, date:, shop:, amount:, account:)
      @id = id
      @date = Date.parse(date)
      @shop = shop
      @amount = amount.to_i
      @account = account
    end

    def save
    end
  end

  class DrWallet::Receipt::Transaction
  end

  def initialize(email:, password:)
    @agent = Mechanize.new
    @logged_in = false

    login(email: email, password: password)
  end

  def login(email:, password:)
    login = @agent.get('https://www.drwallet.jp/login.html')
    form = login.forms.first
    form.field_with(:name => "user[email]").value = email
    form.field_with(:name => "user[password]").value = password
    dashboard = form.submit
    raise DrWallet::LoginFailiureError, "Invalid email or password" if dashboard.uri.to_s !~ /dashboard/
    @logged_in = true
  end

  def accounts
    raise NotLoggedInError if !@logged_in

    accounts = Array.new
    dashboard.search('#expense_account option').each do |account|
      accounts.push(DrWallet::Account.new(account.attribute('value').value.to_i, account.children.first.text))
    end

    return accounts
  end

  def categories
    raise NotLoggedInError if !@logged_in

    categories = Array.new
    dashboard.search('#expense_parent_categories0 option').each do |category|
      categories.push(DrWallet::Account.new(category.attribute('value').value.to_i, category.children.first.text))
    end

    return categories
  end

  def receipts(year:, month:)
    raise NotLoggedInError if !@logged_in

    receipts = Array.new
    JSON.parse(@agent.get("/receipts/after_input_data?year=#{year}&month=#{month}&account_id=").body)['aaData'].each do |receipt|
      receipts.push(DrWallet::Receipt.new(id: receipt[5], date: receipt[0], shop: receipt[1], amount: receipt[2], account: receipt[3]))
    end

    return receipts
  end

  def add_transaction(date:, name:, amount:, shop:, account:, category:)
    raise NotLoggedInError if !@logged_in

    form = dashboard.form_with(:action => "/book_keepings/add_transactions.js")
    form.field_with(:name => 'date').value = Date.parse(date)
    form.field_with(:name => 'transaction[][amount]').value = amount
    form.field_with(:name => 'shop').value = shop
    form.field_with(:name => 'account') {|list| list.option_with(:text => account).select} #.value = accounts.select {|account| account.name == account}.first.id
    form.field_with(:name => 'transaction[][parent_category]') {|list| list.option_with(:text => category).select} #.value = categories.select {|category| category.name == category}.first.id
    form.field_with(:name => 'transaction[][name]').value = name
    form.submit
  end

  :private

  def dashboard
    @agent.get('https://www.drwallet.jp/dashboard/index')
  end

end
