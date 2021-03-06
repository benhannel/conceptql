require_relative 'standard_vocabulary_operator'

module ConceptQL
  module Operators
    class Hcpcs < StandardVocabularyOperator
      register __FILE__

      preferred_name 'HCPCS'
      argument :hcpcs, type: :codelist, vocab: 'HCPCS'
      predominant_domains :procedure_occurrence

      codes_should_match(/^\w{5}$/)

      def table
        :procedure_occurrence
      end

      def vocabulary_id
        5
      end

      def concept_column
        :procedure_concept_id
      end
    end
  end
end

