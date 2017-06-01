$(document).ready(function () {
    $(document.body)
        .on('click', '.manage-sale-events .add-category', function () {
            var sale_events_box = $(this).parents('.manage-sale-events');
            var category_select = sale_events_box.find('#add_category');
            if (category_select.val()) {
                sale_events_box.find('form').prepend(Handlebars.compile($('#sale-event-template').html())({
                    category_id: category_select.val(),
                    category_title: category_select.find('option:selected').text(),
                    uid: Math.round(Math.random() * 10000)
                }));
                category_select.val('');
            }
            else
                alert('Please select category');
            return false;
        })
        .on('click', '.manage-sale-events .remove', function () {
            var sale_category = $(this).parents('.sale-category');
            if (sale_category.hasClass('new'))
                sale_category.remove();
            else
                sale_category.hide().find('.destroy-field').removeAttr('disabled');
            return false;
        });
});