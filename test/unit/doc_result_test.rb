require 'test_helper'

class DocResultTest < ActiveSupport::TestCase
  test 'should return fromSearch' do
    question = nodes(:question)

    result = DocResult.new(
      doc_id: question.nid,
      doc_type: 'QUESTIONS',
      doc_url: question.path(:question),
      doc_title: question.title,
      score: question.answers.length
    )

    assert_equal question.nid,    result.doc_id
    assert_equal 'QUESTIONS',     result.doc_type
  end
end
