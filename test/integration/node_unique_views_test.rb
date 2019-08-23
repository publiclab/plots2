require 'test_helper'

class NodeInsertExtrasTest < ActionDispatch::IntegrationTest
  test 'should get wiki page and record unique views' do
    Impression.delete_all # clear uniques
    assert_equal 0, nodes(:about).views
    assert_equal 0, Impression.count

    assert_difference 'Impression.count', 1 do
      get "/wiki/#{nodes(:about).slug}"

      assert_response :success
    end

    assert_difference 'nodes(:about).reload.views', 0 do
      assert_difference 'Impression.count', 0 do
        get "/wiki/#{nodes(:about).slug}"
        assert_response :success
      end
    end

    assert_equal '127.0.0.1', Impression.last.ip_address
    assert Impression.last.update_attributes(ip_address: '0.0.0.0')

    assert_difference 'nodes(:about).reload.views', 1 do
      assert_difference 'Impression.count', 1 do
        get "/wiki/#{nodes(:about).slug}"
        assert_response :success
      end
    end
  end
end
