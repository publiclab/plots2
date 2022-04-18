//Core component
//= require datatables/jquery.dataTables
//Bootstrap4 theme
//= require datatables/dataTables.bootstrap4

function table_main(id) {
	var table = $(id).DataTable({
		"autoWidth": false,
		"search": {
			"regex": true
		},
		"scrollX": true,
		"info": false,
		"bPaginate": false,
		"language": {
			"search": "Filter displayed results"
		}
	});
	$('#selectall').on('click',function () {
		$('.selectedId').prop('checked', this.checked);
		let selectedLength = $('.selectedId').filter(":checked").length;
		$('#select-count').text(selectedLength);
		disable_buttons('.selectedId');
	});
	$('.selectedId').on('change', function () {
		var check = ($('.selectedId').filter(":checked").length === $('.selectedId').length);
		$('#select-count').text($('.selectedId').filter(":checked").length);
		$('#selectall').prop("checked", check);
		disable_buttons('.selectedId');
	});
	return table;
}

function disable_buttons(id) {
	if ($(id).is(":checked")) {
		$("#batch-spam, #batch-publish, #delete-batch, #batch-ban, #batch-unban").removeClass("disabled");
	} else {
		$("#batch-spam, #batch-publish, #delete-batch, #batch-ban, #batch-unban").addClass("disabled");
	}
}
var pageselect = localStorage.getItem('page-select') || '30';
var filter_value = localStorage.getItem('filter') || 'all';

function pagination(id, url) {
	var currValue = $(id).val();
	localStorage.setItem('page-select', currValue);
	window.location = url + filter_value + "/" + $(id).val();
	$(id).val(pageselect);
}

function search_table(filter, url) {
	localStorage.setItem('filter', filter);
	localStorage.setItem('page-select', pageselect);
	window.location = url + filter + "/30";
	localStorage.setItem('page-select', "30");
}

function batch_nav(bulk) {
	if(bulk == "batch_delete" || bulk == "batch_comment/delete") {
        	let result = confirm("Are you sure you want to delete the selected nodes?");
        	if(!result) return false
	}
	vals = []
	$('.selectedId').each(function (i, a) { // batch nav
		if (a.checked) vals.push(a.value);
	});
	window.location = "/spam2/" + bulk + "/" + vals.join(',');
}

function select_all() {
      $('.selectedId').prop('checked', !$('.selectedId').prop('checked'));
      let selectedLength = $('.selectedId').filter(":checked").length;
      // enable buttons only if there are nodes in the table and number of selected nodes == total node length
       var check = (selectedLength == $('.selectedId').length && selectedLength > 0);
       $('#select-count').text(selectedLength);
       $('#selectall').prop("checked", check);
       disable_buttons('#selectall');
}
