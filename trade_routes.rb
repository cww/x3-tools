#!/usr/bin/env ruby
#
# Copyright (c) 2015 Colin Wetherbee
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'getoptlong'
require 'sqlite3'

USAGE = <<END
Usage: #{__FILE__} -s <sector> [-n num] [-p max_price] [-v volume] [-Ph]
  -h  emit this help text
  -n  number of potential routes to output (default 20)
  -p  maximum price per individual ware
  -P  ignore trading posts
  -s  the name of the sector from which the ship originates (required)
  -v  volume of ship (if provided, can improve ranking algorithm performance)
END

SQL_TRADE_PAIRS = <<END
select
    sgs.station_name as source_station,
    sgb.station_name as dest_station,
    sgs.trading_post as source_trading_post,
    sgb.trading_post as dest_trading_post,
    sgs.good_name as good_name,
    sgs.volume as volume,
    sgb.price_max - sgs.price_min as max_profit,
    sgs.price_min as price_min,
    sgb.price_max as price_max
from sector_goods_bought sgb
join sector_goods_sold sgs on sgb.good_name = sgs.good_name
where
    sgs.sector_name = :source_sector_name
    and sgb.sector_name = :dest_sector_name
END

SQL_SECTOR_NEIGHBORS = <<END
select north, east, south, west
from sector
where name = :sector_name
END

class X3Thing
  attr_reader :sector_name

  def initialize
    @output_size = 20
    @ship_volume = nil
    @user_max_buy_price = nil
    @ignore_trading_posts = nil
    @sector_name = nil
    @sector_search_queue = []
    @sector_search_seen = {}
    # Relax usual database stability concerns since we're always dealing
    # with a local file database; i.e. don't bother testing for a connection
    # regularly, etc.
    @db = SQLite3::Database.new File.expand_path('~/.x3.sqlite3')
  end

  def run!
    _parse_args
    routes = _find_routes
    # Reverse sort so that the highest scores are at the front of the array
    routes = routes.sort { |a,b| b[:score] <=> a[:score] }
    # Print the top N routes
    routes[0 .. @output_size - 1].each do |route|
      puts '%8.1f (% 28s) % 42s -> % 17s/% 42s (dist % 2d pp [% 6d-% 6d] vol %d)' % route.values_at(
        :score, :good_name, :source_station, :end_sector, :dest_station,
        :distance, :price_min, :price_max, :volume)
    end
  end

  private

  def _parse_args
    opts = GetoptLong.new(
      [ '--help',       '-h', GetoptLong::NO_ARGUMENT ],
      [ '--ignore-trading-posts', '-P', GetoptLong::NO_ARGUMENT ],
      [ '--num-output', '-n', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--price',      '-p', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--sector',     '-s', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--volume',     '-v', GetoptLong::REQUIRED_ARGUMENT ],
    )
    errors = []
    opts.each do |opt, arg|
      case opt
        when '--sector'
          if arg && arg.is_a?(String) && arg.length > 0
            @sector_name = arg
          else
            errors.push '--sector requires a sector name'
          end
        when '--num-output'
          begin
            @output_size = Integer(arg)
            errors.push '--num-output requires a positive integer argument' unless @output_size > 0
          rescue ArgumentError
            errors.push '--num-output requires an integer argument'
          end
        when '--price'
          begin
            @user_max_buy_price = Float(arg)
            errors.push '--price requires a positive numeric argument' unless @user_max_buy_price > 0
          rescue ArgumentError
            errors.push '--price requires a numeric argument'
          end
        when '--volume'
          begin
            @ship_volume = Integer(arg)
            errors.push '--volume requires a positive integer argument' unless @ship_volume > 0
          rescue ArgumentError
            errors.push '--volume requires an integer argument'
          end
        when '--ignore-trading-posts'
          @ignore_trading_posts = 1
        when '--help'
          _usage 0
      end
    end

    if !errors.empty?
      errors.each do |err|
        puts "Error: #{err}"
      end
      puts 'Use -h for more help.'
      exit! 1
    end

    if !@sector_name
      puts 'Must specify sector name with -s'
      exit! 42
    end

    puts "Starting from: #{@sector_name}"
  end

  def _usage(code = 1)
    puts USAGE
    exit! code
  end

  def _find_routes
    routes = []
    while (sector = _next_sector)
      begin
        stm = @db.prepare SQL_TRADE_PAIRS
        rs = stm.execute @sector_name, sector[:name]
        rs.each_hash do |row|
          row = row.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo }
          next if @user_max_buy_price && row[:min_buy_price] > @user_max_buy_price
          next if @ignore_trading_posts && (row[:source_trading_post] || row[:dest_trading_post])
          row[:end_sector] = sector[:name]
          row[:distance] = sector[:distance]
          row[:profit_density] = row[:max_profit] / row[:volume]
          row[:score] = row[:profit_density] / Math.sqrt(row[:distance] + 1)
          row[:score] *= Integer(@ship_volume / row[:volume]) if @ship_volume
          row[:score] /= 1000;
          routes.push(row)
        end
      ensure
        stm.close if stm
      end
    end
    return routes
  end

  # returns the next sector to search or nil if there are no more sectors to
  # search
  def _next_sector
    if !@sector_search_queue
      return nil
    end
    if @sector_search_queue.size == 0
      # @sector_search_queue is defined but empty when the search is just
      # beginning, so we prepare the queue here.
      raise ArgumentError, 'Sector name must be provided' unless @sector_name;
      @sector_search_queue.push({ name: @sector_name, distance: 0 })
      @sector_search_seen[@sector_name] = 1
    end
    next_sector = @sector_search_queue.shift
    begin
      stm = @db.prepare SQL_SECTOR_NEIGHBORS
      rs = stm.execute next_sector[:name]
      row = rs.next_hash
      raise ArgumentError, "Unknown sector #{next_sector[:name]}" unless row

      %w(north south east west).each do |dir|
        if row[dir] && !@sector_search_seen[row[dir]]
          @sector_search_queue.push({ name: row[dir], distance: next_sector[:distance] + 1 })
          @sector_search_seen[row[dir]] = 1
        end
      end

      # Setting @sector_search_queue to nil causes this method to return nil
      # the next time it's called, which is what we want after the last element
      # of the queue has been popped.
      @sector_search_queue = nil if @sector_search_queue.empty?
      return next_sector
    ensure
      stm.close if stm
    end
  end
end

if __FILE__ == $0
  x3 = X3Thing.new
  x3.run!
end
