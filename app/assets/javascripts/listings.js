$(document).ready(function () {
    $('body.listings')
        .on('change', '.listing-pricing-form .pricing-type', function () {
            var rows = $(this).parents('.listing-pricing-form').find('[data-pricing-type]');
            rows.hide().find('input, select').attr('disabled', 'disabled');
            rows.filter('[data-pricing-type=' + ($(this).val() || '0') + ']').show().find('input, select').removeAttr('disabled');
        });
});

function setup_pricing_editors_for_ebay_auction(form) {
    var listing_format_input = _.find($('.data-fields .row[data-group=eBay] select[required]'), function (el) {
        return $(el).find('option').text().indexOf('auctionfixed_price') >= 0; // FIXME - yuck!
    });
    if (listing_format_input && listing_format_input.value == 'auction') {
        $(form).find('select.pricing-type').parents('.row').first().hide();
        var rows = $(form).find('[data-pricing-type]');
        rows.hide().find('input, select').attr('disabled', 'disabled');
        rows.filter('[data-pricing-type=auction]').show().find('input, select').removeAttr('disabled');
    }
    else
        $(form).find('select.pricing-type').change().parents('.row').first().show();
}