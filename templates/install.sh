#! /usr/bin/env bash

sudo apt-get update
sudo apt-get install -y ruby
sudo gem install rethinkdb  --no-ri --no-rdoc

cat <<EOF >> /tmp/acme_corp_orders.rb
#! /usr/bin/env ruby

require 'rethinkdb'

database_ip = '${db_internal_ip}'

rql = RethinkDB::RQL.new
connection = rql.connect(host: database_ip, port: 28015)

begin
  rql.db_create('data').run(connection)
rescue RethinkDB::RqlRuntimeError
end

begin
  rql.db('data').table_create('orders').run(connection)
rescue RethinkDB::RqlRuntimeError
end

# http://looneytunes.wikia.com/wiki/List_of_ACME_Products
products = [
  "Acme American Wrought Anvil",
  "Catapult",
  "Hot Air Ballon",
  "Boomerang",
  "Rocket Powered Roller Skates",
  "Super Magnet",
  "Acme Bird Seed",
  "Cannon",
  "Dehydrated Boulders",
  "Earthquake Pills",
  "Rocket Powered Skis",
  "Rocket Powered Unicycle",
  "Quick Dry Cement",
  "Acme Rocket",
  "Bat-Man's Outfit",
  "Acme Matches",
  "Street Cleaners Wagon",
  "Giant Kite Kit",
  "Leg Muscle Vitamins",
  "Acme Glue",
  "Female Road Runner Costume",
  "Smoke Screen Bomb",
  "Artificial Rock",
  "Acme Grease",
  "Triple-Strength Battleship Steel Armor Plate",
  "Giant Rubber Band",
  "Handle Bars",
  "Jet Motor",
  "Jet Bike",
  "Bumble Bees",
  "Giant Rubber Band v2",
  "Tornado Seeds",
  "water pistol",
  "Hi-Speed Tonic",
  "Jet-Propelled Pogo-Stick",
  "Giant Rubber Band V3",
  "Rocket Cart/Sled V1",
  "Iron Pellets V1",
  "Indestructo Steel Ball",
  "Bomb V2",
  "Balloon Basket",
  "Bed Springs",
  "Christmas Package Machine",
  "Roller Skis",
  "Iron Carrot",
  "Iron Bird Seed",
  "Little-Giant Do-It-Yourself Rocket Sled Kit",
  "Instant Icicle Maker",
  "Iron Glue",
  "Super Speed Vitamins",
  "Invisible Paint",
  "Little-Giant Snow Cloud Seeder",
  "Speed Skates",
  "Frisbee Disc",
  "Little Giant - Giant Fire Crackers",
  "Giant Fly Paper",
  "Explosive Tennis Balls",
  "Giant Mouse Trap",
  "Instant Road",
  "Cactus Costume",
  "Lightning Bolts",
]

begin
  connection ||= rql.connect(host: database_ip, port: ENV["RDB_PORT"])

  while true do
    order_hash = {}
    order_hash.store('amount', rand(0..10).to_f)
    order_hash.store('product', products.sample)
    order_hash.store('price', rand(0..100).round(2))
    order_hash.store('customer', 'Wile E. Coyote')
    order_hash.store('purchased_at', Time.now.to_i)

    result = rql.db('data').table('orders').insert(order_hash).run(connection)

    if result['inserted'] == 1
      puts "Customer (#{order_hash['customer']}) " \
           "purchased: #{order_hash['amount']} #{order_hash['product']} @ $#{order_hash['price']}"
    end

    sleep rand(0..5)
  end
rescue => e
  puts "An error has occured, #{e.message}"

  sleep rand(0..5)
  retry
ensure
  connection.close if connection
end
EOF

sudo mv /tmp/acme_corp_orders.rb /usr/local/bin/
sudo chmod +x /usr/local/bin/acme_corp_orders.rb

cat <<EOF >> /tmp/acme_corp_orders.service
[Unit]
Description=ACME Corp Orders
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/acme_corp_orders.rb

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/acme_corp_orders.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable acme_corp_orders
sudo systemctl start acme_corp_orders
