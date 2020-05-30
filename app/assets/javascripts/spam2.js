//Core component
//= require datatables/jquery.dataTables
//Bootstrap4 theme
//= require datatables/dataTables.bootstrap4

function table_main(id) {
	$(id).DataTable({
		"order": [[1, "desc"]],
		"stateSave": true,
		"lengthMenu": [[30, -1, 0], ["Auto", "All", "None"]],
		"autoWidth": false,
		"search": {
			"regex": true
		},
		"info": false,
		"scrollX": true
	});
	$('#selectall').click(function () {
		$('.selectedId').prop('checked', this.checked);
	});
	$('.selectedId').change(function () {
		var check = ($('.selectedId').filter(":checked").length == $('.selectedId').length);
		$('#selectall').prop("checked", check);
	});
}