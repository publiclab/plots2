function table_main(id) {
	var table = $(id).DataTable({
		"order": [[1, "desc"]],
		"stateSave": false,
		"lengthMenu": [[30, -1, 0], ["Auto", "All", "None"]],
		"autoWidth": false,
		"search": {
			"regex": true
		},
		"info": false,
		"scrollX": true,
		"fixedHeader": true
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