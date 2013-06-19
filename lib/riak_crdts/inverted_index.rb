require 'riak_crdts/crdts/g_set'

module RiakCrdts
  class InvertedIndex

    attr_accessor :index_bucket_name, :index_bucket, :client, :base_bucket_name

    def initialize(client, bucket_name)
      self.client = client
      self.base_bucket_name = bucket_name
      self.index_bucket_name = "#{bucket_name}_indexes"
      self.index_bucket = client.bucket(self.index_bucket_name)
      if !self.index_bucket.allow_mult
        self.index_bucket.allow_mult = true
      end
    end

    def put_index(index_name, key)
      index = GSet.new
      index.add(key)

      object = self.index_bucket.new(index_name)
      object.content_type = 'text/plain'
      object.raw_data = index.to_json

      object.store(options={:returnbody => false})
    end

    def get_index(index_name)
      index_obj = self.index_bucket.get_or_new(index_name)

      index = GSet.new

      # If resolving siblings...
      if index_obj.siblings.length > 1
        index_obj.siblings.each { | obj |
          unless obj.raw_data.nil? or obj.raw_data.empty?
            index.merge_json obj.raw_data
          end
        }

        resolved_obj = self.index_bucket.new(index_name)
        resolved_obj.vclock = index_obj.vclock

        # previous content type was mulitpart/mixed, reset to something more innocuous
        resolved_obj.content_type = 'text/plain'
        resolved_obj.raw_data = index.to_json
        resolved_obj.store(options={:returnbody => false})
      elsif !index_obj.raw_data.nil?
        index.merge_json(index_obj.raw_data)
      end

      return index
    end

    def index_objects(index_name)
      index = get_index(index_name)

      index.members.each do |key|
        obj = client[self.base_bucket_name].get(key)
        unless obj.nil?
          yield obj
        end
      end
    end
  end
end