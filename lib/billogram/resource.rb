require "active_support/core_ext/string/inflections.rb"

module Billogram
  class Resource
    DEFAULT_OPTIONS = { page: 1, page_size: 50 }

    class << self
      def relations
        @relations ||= []
      end

      def endpoint(value = nil)
        @endpoint = value if value
        @endpoint || name.demodulize.underscore
      end

      def search(options = {})
        query = DEFAULT_OPTIONS.merge(options)
        perform_request("#{endpoint}", :get, query)
      end

      def fetch(id = nil)
        perform_request("#{endpoint}/#{id}", :get)
      end

      def create(attributes)
        perform_request("#{endpoint}", :post, attributes)
      end

      def update(id, attributes)
        perform_request("#{endpoint}/#{id}", :put, attributes)
      end

      def delete(id)
        perform_request("#{endpoint}/#{id}", :delete)
      end

      def relation(name, type, class_override: nil)
        relations << Relation.new(name, type, class_override: class_override)
        attr_accessor name
      end

      def build_objects(data)
        case data
        when Hash then new(data)
        when Array then data.map{|item| build_objects(item) }
        else data
        end
      end

      def perform_request(url, type, params = {})
        case type
        when :post, :put
          query = { body: params.to_json }
        when :get
          query = { query: params }
        when :delete
          query = {}
        end

        response = Billogram.client.send(type, url, query)
        build_objects(response)
      end
    end

    def initialize(attributes = {})
      Hash(attributes).each do |key, value|
        public_send("#{key}=", value) if respond_to?(key)
      end

      RelationBuilder.new(self, attributes).call
    end

    def update(attributes)
      self.class.update(id, attributes)
    end

    def delete
      self.class.delete(id)
    end

    def perform_request(*args)
      self.class.perform_request(*args)
    end

    def endpoint
      self.class.endpoint
    end

    def to_json(*args)
      instance_variables
        .map{|var| ["#{var}"[1..-1], instance_variable_get(var)]}
        .to_h
        .to_json(*args)
    end
  end
end
