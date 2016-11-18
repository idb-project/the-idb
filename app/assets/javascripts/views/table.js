// calculate the number of cores and memory selected by the filter
$(function() {
  $('table')
    .bind('filterEnd', function() {
      var totalCores = 0;
      var totalMemory = 0;
      // ignore summary row
      $(this).find('tbody:not(".summary") tr:visible').each(function(){
        // cores in sixth column
        totalCores += $(this).find('td:eq(7)').text() == ""?0:parseFloat($(this).find('td:eq(7)').text());
        // memory in seventh column
        totalMemory += $(this).find('td:eq(8)').text() == ""?0:parseFloat($(this).find('td:eq(8)').text());
      });

      $('.total-cores').text(totalCores + " C");
      $('.total-memory').text(Math.round(totalMemory) + " GB");
      $('.summary-td').html('Summary');

      // find out if only one vmhost is filtered
      // the vmhost of the first filtered machine, use it as reference
      var vmhost = $(this).find('tbody:not(".summary") tr:visible').find('td:eq(10)').first().text();
      if (vmhost != "") {
        var vmhost_selected = true;
        $(this).find('tbody:not(".summary") tr:visible').each(function() {
          var vmhost_td = $(this).find('td:eq(10)').text();
          if(vmhost_td != vmhost || vmhost_td == "n/a" || vmhost_td == "") {
            // we found a row with a machine that has a different vmhost assigned
            vmhost_selected = false;
          }
        });

        if (vmhost_selected) {
          // all filtered machines have the same vmhost assigned

          // enhance the core summary by the vmhost data
          $('.total-cores').html($('.total-cores').text() + " /<br/> " + $(this).find('tbody:not(".summary")').find(':hidden').find("td:eq(1):contains('"+vmhost+"')").parent().find('td:eq(7)').text() + " C");
          // enhance the memory summary by the vmhost data
          $('.total-memory').html($('.total-memory').text() + " /<br/> " + $(this).find('tbody:not(".summary")').find(':hidden').find("td:eq(1):contains('"+vmhost+"')").parent().find('td:eq(8)').text());
          // list the vmhost name as additional indicator
          $('.summary-td').html("Summary of<br/>" + vmhost);
        }
      }
    });
});

IDB.Views.Table = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    var view = this;
  }
});
