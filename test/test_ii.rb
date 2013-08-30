require 'test/unit'
require 'riak'
require_relative '../lib/riak_crdts'

class RiakTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # requires local riak instance
  def test_index
    client = Riak::Client.new(:protocol => 'http')
    Riak.disable_list_keys_warnings = true

    bucket_name = 'bob'
    index_name = 'this_old_index'

    inv_index = RiakCrdts::InvertedIndex.new(client, bucket_name)

    total = 0
    (1..10).each do |i|
      inv_index.put_index(index_name, i.to_s)
      total += i
    end

    test_total = 0
    index_values = inv_index.get_index(index_name)

    index_values.members.each do |x|
      test_total += x.to_i
    end

    del_bucket = inv_index.index_bucket_name
    client[del_bucket].keys.each do |key|
      client[del_bucket][key].delete
    end

    puts "Index count - ref: #{total} - test: #{test_total}"


    assert(total == test_total)
    puts total
    obj_total = 0
    (11..20).each do |x|
      obj = client[bucket_name].new(x.to_s)
      obj.data = x.to_s
      obj.store

      inv_index.put_index(index_name, x.to_s)
      obj_total += x
    end

    test_obj_total = 0


    inv_index.index_objects(index_name) { |obj|
      test_obj_total += obj.data.to_i
    }

    puts "Object count - ref: #{obj_total} - test: #{test_obj_total}"
    assert(obj_total == test_obj_total)

    #cleanup
    client[del_bucket].keys.each do |key|
      client[del_bucket][key].delete
    end
    client[bucket_name].keys.each do |key|
      client[bucket_name][key].delete
    end
  end
end
