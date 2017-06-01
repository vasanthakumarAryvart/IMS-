$(document).ready(function () {
    $('body').on('click', '.orders-list .order-details-trigger', function () {
        var that = $(this).parents('tr').next('.order-details');
        $(this).parents('table').find('.order-details').not(that).toggle(false);
        that.toggle();
        return false;
    });
});