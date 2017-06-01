$(document).ready(function () {
    $('[data-filter-content]').on('change', 'select, input', function () {
        var filter = $(this).parents('[data-filter-content]');
        if ($(this)[0].name != 'page')
            filter.find('input[name=page]').remove();
        $('#' + filter.data('filter-content')).html('<div style="padding: 8px 0px;" class="text-center"><i class="fa fa-refresh infinite-spin"></i></div>')
        var params = filter.serialize();
        filter.find('input, select').attr('disabled', 'disabled');
        $.get(filter.data('filter-url'), params, function (html) {
            $('#' + filter.data('filter-content')).html(html).find('.sortable').each(function (i, el) {
                sorttable.makeSortable(el);
            });
            filter.find('input, select').removeAttr('disabled');
        });
    }).submit(function () {
        return false;
    }).find('select, input').first().change();
    $('body').on('click', '.pagination.ajax-filter-pagination a', function () {
        var filter = $('[data-filter-content]');
        filter.find('input[name=page]').remove();
        filter.append('<input name="page" type="hidden"/>');
        filter.find('input[name=page]').val($(this)[0].href.match(/page=(\d)+/)[0].replace('page=', '')).change();
        return false;
    })
});