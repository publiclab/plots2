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
			"search": "Search in this page"
		}
	});
	$('#selectall').click(function () {
		$('.selectedId').prop('checked', this.checked);
		$('#select-count').text($('.selectedId').filter(":checked").length);
		disable_buttons('#selectall');
	});
	$('.selectedId').change(function () {
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
	vals = []
	$('.selectedId').each(function (i, a) { // batch nav
		if (a.checked) vals.push(a.value);
	});
	window.location = "/spam2/" + bulk + "/" + vals.join(',');
}