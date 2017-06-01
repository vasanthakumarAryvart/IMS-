// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require magic-edge-inc
//= require magic-edge
//= require farbtastic
//= require filters

//= require highcharts
// to get the new features in 2.3.0:
//= require highcharts/highcharts-more

//= require_tree .

$(document).ready(function () {
    $('body')
        .on('focus', ".date-field", function () {
            $(this).datepicker({dateFormat: "yy-mm-dd"});
        })
        .on('click', ".checkbox-switch", function () {
            if (!$(this).hasClass('disabled'))
                var chackbox = $(this).parent().find('input[type=checkbox]');
            if ($(this).hasClass('on')) {
                chackbox[0].checked = false;
                $(this).removeClass('on');
            } else {
                chackbox[0].checked = true;
                $(this).addClass('on');
            }
            chackbox.change();
        })
        .on('click', ".no-click", function () {
            return false;   
        })
        .on('click', '.string-list-input .add-item', function () {
            var input = $(this).parents('.string-list-input');
            if (input.data('max-items') && parseInt(input.data('max-items')) <= input.find('.string-list-items').children().length)
                alert("Max number of items reached");
            else {
                var template = Handlebars.compile(input.find('.item-template').html())({
                    id: $(this).data('id'),
                    rnd: Math.round(Math.random() * 10000000)
                });
                input.find('.string-list-items').append(template);
            }
            return false;
        })
        .on('click', '.string-list-input .remove', function () {
            $(this).parent().remove();
            return false;
        })
});