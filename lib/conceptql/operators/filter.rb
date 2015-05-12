require_relative 'binary_operator_node'

module ConceptQL
  module Operators
    class Filter < BinaryOperatorOperator
      desc 'Only pass through results from the LHR that have a corresponding RHR with the same person, criterion_id, and criterion_type'

      def query(db)
        rhs = right.evaluate(db)
        rhs = rhs.select_group(:person_id, :criterion_id, :criterion_type)
        query = db.from(Sequel.as(left.evaluate(db), :l))
        query = query
          .left_join(Sequel.as(rhs, :r), l__person_id: :r__person_id, l__criterion_id: :r__criterion_id, l__criterion_type: :r__criterion_type)
          .exclude(r__criterion_id: nil)
          .select_all(:l)
        db.from(query)
      end
    end
  end
end

