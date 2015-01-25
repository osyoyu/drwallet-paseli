drwallet-paseli
===============

なんこれ
--------
PASELIのサイトから利用履歴を引っ張ってきて、Dr.Walletに突っ込むスクリプトです。現金しか使わないSDVXerとかには関係ないです。

使い方
------
1. Dr.Wallet にPASELI用の口座とカテゴリーを作る（デフォルトで存在するものを指定することも可能ですが、専用のものを作成することをおすすめします）
2. `main.rb` の `DRWALLET_ACCOUNT_NAME` と `DRWALLET_CATEGORY_NAME` に 1. で作成した口座とカテゴリーの名前を設定する。
3. `main.rb` の `KONAMI_ID` と `KONAMI_PASSWORD` 、 `DRWALLET_EMAIL` と `DRWALLET_PASSWORD` を設定する。
4. `ruby main.rb` を叩くと、PASELIの利用履歴に残っている全ての履歴がDr.Walletに書き込まれます（既に書き込まれたものでも二重に登録されるので注意、なんとかします）。

動作要件
--------
Ruby 2.1 以上

ライセンス
----------
MIT
