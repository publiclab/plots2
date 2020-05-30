//Core component
//= require datatables/jquery.dataTables
//Bootstrap4 theme
//= require datatables/dataTables.bootstrap4

function table_main(id) {
	// DataTable used in spam2
	$(id).DataTable({
		"order": [
			[1, "asc"]
		],
		stateSave: true,
		"lengthMenu": [
			[30, -1, 0],
			["Auto", "All", "None"]
		],
		"autoWidth": false,
		"search": {
			"regex": true
		},
		"info": false,
		"scrollX": true,
	});
	// select all checkbox
	$('#selectall').click(function () {
		$('.selectedId').prop('checked', this.checked);
	});
	$('.selectedId').change(function () {
		var check = ($('.selectedId').filter(":checked").length == $('.selectedId').length);
		$('#selectall').prop("checked", check);
	});
	// batch spam and alert if no item is selected
	$('#batch-spam').bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		if (vals.length == 0) {
			alert("You have selected nothing, Please select something")
		} else {
			window.location = "/spam2/batch_spam/" + vals.join(',')
		}
	});
}

function bulk_nav() {
	// select all button
	$('#all').click(function () {
		$('.selectedId').prop('checked', !$('.selectedId').prop('checked'));
		var check = ($('.selectedId').filter(":checked").length == $('.selectedId').length);
		$('#selectall').prop("checked", check);
	});
	// batch publish and alert if no item is selected
	$('#batch-publish').bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		if (vals.length == 0) {
			alert("You have selected nothing, Please select something")
		} else {
			window.location = "/spam2/batch_publish/" + vals.join(',')
		}
	});
	// batch ban and alert if no item is selected
	$('#batch-ban').bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		if (vals.length == 0) {
			alert("You have selected nothing, Please select something")
		} else {
			window.location = "/spam2/batch_ban/" + vals.join(',')
		}
	});
	// batch delete and alert if no item is selected
	$('#delete-batch').bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		if (vals.length == 0) {
			alert("You have selected nothing, Please select something")
		} else {
			if (confirm("Are you sure you want to delete this?")) {
				window.location = "/spam2/batch_delete/" + vals.join(',')
			} else {
				return false;
			}
		}
	});
}