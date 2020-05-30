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

function select_all(id) {
	$(id).click(function () {
		$('.selectedId').prop('checked', !$('.selectedId').prop('checked'));
		var check = ($('.selectedId').filter(":checked").length == $('.selectedId').length);
		$('#selectall').prop("checked", check);
	});
}

function batch_spam(id) {
	$(id).bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		window.location = "/spam2/batch_spam/" + vals.join(',')
	});
}

function batch_publish(id) {
	$(id).bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		window.location = "/spam2/batch_publish/" + vals.join(',')
	});
}

function batch_ban(id) {
	$(id).bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		window.location = "/spam2/batch_ban/" + vals.join(',')
	});
}

function batch_delete(id) {
	$(id).bind('click', function (e) {
		vals = []
		$('.selectedId').each(function (i, a) {
			if (a.checked) vals.push(a.value)
		})
		window.location = "/spam2/batch_delete/" + vals.join(',')
	});
}