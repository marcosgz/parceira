parceira
========

Importing of CSV Files as Array(s) of Hashes with featured to process large csv files and better support for file encoding.

## Installation

Add this line to your application's Gemfile:

    gem 'parceira'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parceira

## Usage

```bash
$ cat example/products.csv
Product ID,Name,Price
1,Macbook Air,999
2,Ipad mini,329.99
3,Iphone 5,199.00
4,MacBook Pro,
```

```ruby
> require 'parceira'
> filename = File.expand_path('./../example/products.csv', __FILE__)
> Parceira.process(filename)
=> [{:product_id=>1, :name=>"Macbook Air", :price=>999}, {:product_id=>2, :name=>"Ipad mini", :price=>329.99}, {:product_id=>3, :name=>"Iphone 5", :price=>199.0}, {:product_id=>4, :name=>"MacBook Pro", :price=>nil}]

> Parceira.process(filename, key_mapping: {name: :description})
=> [{:product_id=>1, :description=>"Macbook Air", :price=>999}, {:product_id=>2, :description=>"Ipad mini", :price=>329.99}, {:product_id=>3, :description=>"Iphone 5", :price=>199.0}, {:product_id=>4, :description=>"MacBook Pro", :price=>nil}]

> Parceira.process(filename, reject_nil: true)
=> [{:product_id=>1, :name=>"Macbook Air", :price=>999}, {:product_id=>2, :name=>"Ipad mini", :price=>329.99}, {:product_id=>3, :name=>"Iphone 5", :price=>199.0}, {:product_id=>4, :name=>"MacBook Pro"}]

> Parceira.process(filename, reject_matching: /^Macbook/i)
=> [{:product_id=>1, :name=>nil, :price=>999}, {:product_id=>2, :name=>"Ipad mini", :price=>329.99}, {:product_id=>3, :name=>"Iphone 5", :price=>199.0}, {:product_id=>4, :name=>nil, :price=>nil}]

> Parceira.process(filename, file_encoding: 'utf-8')
=> [{:product_id=>1, :name=>"Macbook Air", :price=>999}, {:product_id=>2, :name=>"Ipad mini", :price=>329.99}, {:product_id=>3, :name=>"Iphone 5", :price=>199.0}, {:product_id=>4, :name=>"MacBook Pro", :price=>nil}]

> Parceira.process(filename, headers: false)
=> [[1, "Macbook Air", 999], [2, "Ipad mini", 329.99], [3, "Iphone 5", 199.0], [4, "MacBook Pro", nil]]

> Parceira.process(filename, headers: false, headers_included: false)
=> [["Product ID", "Name", "Price"], [1, "Macbook Air", 999], [2, "Ipad mini", 329.99], [3, "Iphone 5", 199.0], [4, "MacBook Pro", nil]]

> Parceira.process(filename, headers: %w(ID Name Value))
=> [{"ID"=>1, "Name"=>"Macbook Air", "Value"=>999}, {"ID"=>2, "Name"=>"Ipad mini", "Value"=>329.99}, {"ID"=>3, "Name"=>"Iphone 5", "Value"=>199.0}, {"ID"=>4, "Name"=>"MacBook Pro", "Value"=>nil}]
```


## Reporting Bugs / Feature Requests
Please [open an Issue on GitHub](https://github.com/marcosgz/parceira/issues) if you have feedback, new feature requests, or want to report a bug. Thank you!


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
