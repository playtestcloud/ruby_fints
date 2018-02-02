ruby_fints
==========

This is a pure-Ruby implementation of FinTS (formerly known as HBCI), a
online-banking protocol commonly supported by German banks.

Limitations
-----------

* Only FinTS 3.0 is supported
* Only PIN/TAN authentication is supported, no signature cards
* Only a number of reading operations are currently supported
* Supports Ruby 2.2+

Banks tested:

* Sparkasse
* ING DiBa
* GLS Bank

Usage
-----

```ruby
require 'ruby_fints'
require 'pp'

FinTS::Client.logger.level = Logger::DEBUG
f = FinTS::PinTanClient.new(
    '123456789',  # Your bank's BLZ
    'myusername',
    'mypin',
    'https://mybank.com/...'  # endpoint, e.g.: https://hbci-pintan.gad.de/cgi-bin/hbciservlet
)

accounts = f.get_sepa_accounts
pp accounts
# [{iban: 'DE12345678901234567890', bic: 'ABCDEFGH1DEF', accountnumber: '123456790', subaccount: '', blz: '123456789'}]

statement = f.get_statement(accounts[0], Date.new(2017, 4, 3), Date.new(2017, 4, 4))
pp statement.map(&:data)

# [#<Cmxl::Fields::Transaction:0x007fab6b457ec8
#  @data=
#   {"date"=>"170404",
#    "entry_date"=>"0404",
#    "funds_code"=>"C",
#    "currency_letter"=>"R",
#    "amount"=>"96,38",
#    "swift_code"=>"N062",
#    "reference"=>"NONREF",
#    "bank_reference"=>""},
#  @details=
#   #<Cmxl::Fields::StatementDetails:0x007fab6b457838
#    @data=
#     {"transaction_code"=>"166",
#      "details"=>
#       "?00GUTSCHRIFT?109251?20EREF+010F209270562741?21SVWZ+STRIPEX4J1J3?22AWV-MELDEPFLICHT BEACHTEN?23HOTLINE BUNDESBANK.?24(0800) 1234-111?30SXPYDKKK?35DK6689000000010241?32Stripe Payments UK Ltd?34888",
#      "seperator"=>"?"}
#  ]

# for retrieving the holdings of an account (This has not been tested for this implementation yet so it might not work)
holdings = f.get_holdings(accounts[0])
```

Credits
-------

This is a close port of [python-fints](https://github.com/raphaelm/python-fints) library by Raphael Michel
which in turn is a port of the [fints-hbci-php](https://github.com/mschindler83/fints-hbci-php)
implementation that was released by Markus Schindler under the MIT license.

Thanks for your work!
