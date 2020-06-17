//Core component
//= require datatables/jquery.dataTables
//Bootstrap4 theme
//= require datatables/dataTables.bootstrap4

function table_main(id) {
	var table = $(id).DataTable({
		"order": [[1, "desc"]],
		"stateSave": false,
		"autoWidth": false,
		"search": {
			"regex": true
		},
		"scrollX": true
	});
	$('#selectall').click(function () {
		$('.selectedId').prop('checked', this.checked);
		$('#select-count').text($('.selectedId').filter(":checked").length);
	});
	$('.selectedId').change(function () {
		var check = ($('.selectedId').filter(":checked").length === $('.selectedId').length);
		$('#select-count').text($('.selectedId').filter(":checked").length);
		$('#selectall').prop("checked", check);
	});
	return table;
}
