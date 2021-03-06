require_relative 'operator'

module ConceptQL
  module Operators
    class PassThru < Operator
      register __FILE__

      basic_type :set
      no_desc

      def domains
        domains = upstreams.map(&:domains).flatten.uniq
        domains.empty? ? [:invalid] : domains
      end

      def query_cols
        upstreams.first.query_cols
      end
    end
  end
end
