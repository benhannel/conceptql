require 'spec_helper'
require 'conceptql/operators/started_by'
require_double('stream_for_temporal')

describe ConceptQL::Operators::StartedBy do
  it_behaves_like(:temporal_operator)
  subject do
    described_class.new(left: StreamForTemporalDouble.new, right: StreamForTemporalDouble.new)
  end

  it 'should use proper where clause' do
    expect(subject.query(Sequel.mock).sql).to match('l.start_date = r.start_date')
    expect(subject.query(Sequel.mock).sql).to match('l.end_date > r.end_date')
  end

  it 'should use proper where clause when inclusive' do
    sub = ConceptQL::Operators::StartedBy.new(left: StreamForTemporalDouble.new, right: StreamForTemporalDouble.new, inclusive: true)
    expect(sub.query(Sequel.mock).sql).to match('l.start_date = r.start_date')
    expect(sub.query(Sequel.mock).sql).to match('l.end_date >= r.end_date')
  end
end
