require_relative 'operator'
require_relative '../date_adjuster'

module ConceptQL
  module Operators
    class ConcurrentWithin < Operator
      register __FILE__

      desc 'Filters each upstream to only include rows where there are matching entries in each of the other upstreams.'
      option :start, type: :string
      option :end, type: :string
      allows_many_upstreams
      validate_at_least_one_upstream
      validate_no_arguments
      validate_option DateAdjuster::VALID_INPUT, :start, :end
      category "Modify Data"
      basic_type :temporal
      default_query_columns

      def query(db)
        datasets = upstreams.map do |stream|
          stream.evaluate(db)
        end

        return datasets.first.from_self if datasets.length == 1

        adjusted_start_date = DateAdjuster.new(options[:start]).adjust(:l__start_date, true)
        adjusted_end_date = DateAdjuster.new(options[:end]).adjust(:l__end_date)

        datasets = datasets.map do |ds|
          matching = ds.from_self(:alias=>:l)

          (datasets - [ds]).each do |other|
            other = other
              .from_self(:alias=>:r)
              .where(adjusted_start_date <= :r__start_date)
              .where(adjusted_end_date >= :r__end_date)
              .select(:person_id)

            matching = matching.where(:person_id=>other)
          end

          matching
        end

        ds, *rest = datasets
        rest.each do |other|
          ds = ds.union(other, :from_self=>nil)
        end

        ds.from_self
      end
    end
  end
end


