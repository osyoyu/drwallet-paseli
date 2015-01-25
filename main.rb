# coding: UTF-8

require_relative 'drwallet.rb'
require_relative 'paseli.rb'

DRWALLET_ACCOUNT_NAME  = "PASELI"
DRWALLET_CATEGORY_NAME = "ゲーセン"

KONAMI_ID         = ''
KONAMI_PASSWORD   = ''
DRWALLET_EMAIL    = ''
DRWALLET_PASSWORD = ''

mykonami = PASELI.new(konami_id: KONAMI_ID, password: KONAMI_PASSWORD)
drwallet = DrWallet.new(email: DRWALLET_EMAIL, password: DRWALLET_PASSWORD)
mykonami.paseli_history.each do |history|
  drwallet.add_transaction(date: history.date.strftime('%Y/%m/%d'), name: history.name, amount: history.amount, account: DRWALLET_ACCOUNT_NAME, category: DRWALLET_CATEGORY_NAME, shop: history.name)
end
