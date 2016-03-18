require_relative 'operator'

module ConceptQL
  module Operators
    class Visit < Operator
      register __FILE__, :omopv4

      desc 'Generates all visit_occurrence records, or, if fed a stream, fetches all visit_occurrence records for the people represented in the incoming result set.'
      domains :visit_occurrence
      allows_one_upstream
      validate_at_most_one_upstream
      validate_no_arguments
      query_columns :visit_occurrence

      def query(db)
        ds = db.from(:visit_occurrence)
        if upstream = upstreams.first
          ds = ds.where(:person_id=>upstream.query(db).select(:person_id))
        end
        ds
      end

      def domains
        [:visit_occurrence]
      end
    end
  end
end
