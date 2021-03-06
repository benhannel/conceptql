require_relative 'helper'
require_relative 'db'
require_relative '../lib/conceptql/query'
require_relative '../lib/conceptql/database'

describe ConceptQL::Operators do 

  dbConnection = ConceptQL::Database.new(DB)

  it "should list codes and descriptions" do 
    query = dbConnection.query(["union",["cpt","99214"],["icd9", "250.00", "250.02"]])
    query.code_list(DB).must_equal(
        [
            [
                "Cpt 99214: Office or other outpatient visit for the evaluation and management of an established patient, which requires at least 2 of these 3 key components: A detailed history; A detailed examination; Medical decision making of moderate complexity. Counseling and/o"
            ],
            [
                "Icd9 250.00: Diabetes mellitus without mention of complication, type II or unspecified type, not stated as uncontrolled",
                "Icd9 250.02: Diabetes mellitus without mention of complication, type II or unspecified type, uncontrolled"
            ]
        ])
  end
end