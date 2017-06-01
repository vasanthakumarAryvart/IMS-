$(document).ready(function () {
    $('.admin-categories .categories-list .expand-category[data-id]').click(function () {
        if ($(this).html() == '+') {
            $('.admin-categories .categories-list tr[data-parent-id=' + $(this).data('id') + ']').show();
            $(this).html('–');
        } else if ($(this).html() == '–') {
            var first_child = $('.admin-categories .categories-list tr[data-parent-id=' + $(this).data('id') + ']').hide().find('.expand-category[data-id]:first');
            if (first_child.html() == '–')
                first_child.click();
            $(this).html('+');
        }
    });
});