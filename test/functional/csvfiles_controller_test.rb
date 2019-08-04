require 'test_helper'

class CsvfilesControllerTest < ActionController::TestCase
	def setup
		activate_authlogic
	end

	test 'should save csv file' do
		post :setter, params: {uid: 2, filetitle: "Test Title", filedescription: "Test Description", object: '{"completeCsvMatrix":[[1,6,11,16,21,26,null],[2,7,12,17,22,27,null],[3,8,14,18,23,28,null],[4,9,14,19,24,29,null],[5,10,15,20,25,30,null]],"csvHeaders":["A1","B1","Column3","C1","Column5"],"csvSampleData":[[1,6,11,16,21],[2,7,12,17,22],[3,8,14,18,23],[4,9,14,19,24],[5,10,15,20,25]],"csvValidForYAxis":["A1","B1","Column3","C1","Column5"],"completeCsvMatrixTranspose":[["A1","B1","Column3","C1","Column5"],[1,2,3,4,5],[6,7,8,9,10],[11,12,14,14,15],[16,17,18,19,20],[21,22,23,24,25],[26,27,28,29,30],[null,null,null,null,null]]}', filestring: 'data:text/csv;charset=utf-8,A1,B1,Column3,C1,Column5%0A1,2,3,4,5%0A6,7,8,9,10%0A11,12,14,14,15%0A16,17,18,19,20%0A21,22,23,24,25%0A26,27,28,29,30%0A'}
		assert_response :success
	end

	test 'should get previous files' do
		get :prev_files, params: {uid: 2}
		assert_response :success
	end

	test 'should not get user files if not logged in'  do
		get :user_files, params: {id: 2}
		assert_redirected_to '/login'
	end

	test 'should save graph object' do
		post :add_graphobject, params: {uid: 2, filetitle: "Test Title", filedescription: "Test Description", object: '{"completeCsvMatrix":[[1,6,11,16,21,26,null],[2,7,12,17,22,27,null],[3,8,14,18,23,28,null],[4,9,14,19,24,29,null],[5,10,15,20,25,30,null]],"csvHeaders":["A1","B1","Column3","C1","Column5"],"csvSampleData":[[1,6,11,16,21],[2,7,12,17,22],[3,8,14,18,23],[4,9,14,19,24],[5,10,15,20,25]],"csvValidForYAxis":["A1","B1","Column3","C1","Column5"],"completeCsvMatrixTranspose":[["A1","B1","Column3","C1","Column5"],[1,2,3,4,5],[6,7,8,9,10],[11,12,14,14,15],[16,17,18,19,20],[21,22,23,24,25],[26,27,28,29,30],[null,null,null,null,null]]}', filestring: 'data:text/csv;charset=utf-8,A1,B1,Column3,C1,Column5%0A1,2,3,4,5%0A6,7,8,9,10%0A11,12,14,14,15%0A16,17,18,19,20%0A21,22,23,24,25%0A26,27,28,29,30%0A',graphobject: '{"hash": {"x_axis_labels": [3,8,14,18,23,28,null],"y_axis_values0": [2,7,12,17,22,27,null],"labels": ["Column3",["B1"]],"graphType": "Horizontal","length": 1}'}
		assert_response :success
	end

	test 'should not delete a user file if not logged in'  do
		get :delete, params: {id: 60, uid: 2}
		assert_redirected_to '/login'
	end

	test 'should fetch graph object' do
		get :fetch_graphobject, params: {id: 60, uid: 2}
		assert_response :success
	end
    
end