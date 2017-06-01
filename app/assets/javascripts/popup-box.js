$(document).ready(function () {
    $(document.body)
        .on('click', '[data-open-popup]', function () {
            var popup_box = $('[data-popup-box="' + $(this).data('open-popup') + '"]');
            var popup_overlay = popup_box.parents('.popup-box-overlay');
            if (popup_overlay.length == 0) {
                popup_overlay = $(popup_box).parent().append('<div class="popup-box-overlay"><div class="popup-container"></div></div>').children().last().hide();
                popup_overlay.find('.popup-container').append(popup_box.clone().data('popup-reuse', $(this).data('popup-reuse')).show());
                //popup_overlay.fadeIn(150);
                popup_overlay.show();
            }
            else
                popup_overlay.fadeIn(150);
            if (popup_box.data('init'))
                (function () {
                    eval(popup_box.data('init'));
                }).apply(popup_overlay.find('[data-popup-box]')[0]);
            return false;
        })
        .on('click', '.popup-box-overlay .popup-close', function () {
            var popup_overlay = $(this).parents('.popup-box-overlay');
            if (popup_overlay.length > 0)
                popup_overlay.fadeOut(150, function () {
                    if (!popup_overlay.find('[data-popup-box]').data('popup-reuse'))
                        popup_overlay.remove();
                });
            return false;
        })
        .on('click', '[data-popup-url]', function () {
            $that = $(this);
            $.get($(this).data('popup-url'), function (html) {
                openModalPopup(html, {width: $that.data('popup-width')});
            });
            return false;
        })
        .on('click', '.popup-box-overlay, .popup-container', function (e) {
            var overlay = $(this).hasClass('popup-box-overlay') ? $(this) : $(this).parent();
            if (e.target == e.currentTarget)
                overlay.fadeOut(150, function () {
                    if (!overlay.find('[data-popup-box]').data('popup-reuse'))
                        overlay.remove();
                });
        })
});

function openModalPopup(html, options) {
    options = options || {};
    var popup_overlay = $(document.body).append('<div class="popup-box-overlay"><div class="popup-container"></div></div>').children().last().hide();
    popup_overlay.fadeIn(150);
    popup_overlay.find('.popup-container').append(html);
    if (options.width) {
        popup_overlay.find('.popup-container > .light-container').css({width: options.width + 'px'})
    }
}
