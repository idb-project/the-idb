// calculate the number of cores and memory selected by the filter
$(function() {
  $('#machine-table')
    .bind('filterEnd', function() {
      var totalCores = 0;
      var totalMemory = 0;
      var totalDisk = 0;
      var totalRows = 0;
      // ignore summary row
      $('#machine-table').find('tbody:not(".summary") tr:visible').each(function() {
        // cores in fifth column
        totalCores += $(this).find('td:eq(4)').text() == ""?0:parseFloat($(this).find('td:eq(4)').text());
        // memory in sixth column
        totalMemory += $(this).find('td:eq(5)').text() == ""?0:parseFloat($(this).find('td:eq(5)').text());
        // memory in seventh column
        totalDisk += $(this).find('td:eq(6)').text() == ""?0:parseFloat($(this).find('td:eq(6)').text());
      });
      // count selected rows
      totalRows = $('#machine-table').find('tbody:not(".summary") tr:visible').length;

      $('.total-cores').text(totalCores + " C");
      $('.total-memory').text(Math.round(totalMemory) + " GB");
      $('.total-diskspace').text(totalDisk.toFixed(1) + " TB");
      $('.summary-td').html('Machines: '+totalRows);

      // find out if only one vmhost is filtered
      // the vmhost of the first filtered machine, use it as reference
      var vmhost = $('#machine-table').find('tbody:not(".summary") tr:visible').find('td:eq(7)').first().text();
      if (vmhost != "") {
        var vmhost_selected = true;
        $('#machine-table').find('tbody:not(".summary") tr:visible').each(function() {
          var vmhost_td = $('#machine-table').find('td:eq(7)').text();
          if(!vmhost_td.startsWith(vmhost) || vmhost_td == "n/a" || vmhost_td == "") {
            // we found a row with a machine that has a different vmhost assigned
            vmhost_selected = false;
          }
        });

        if (vmhost_selected) {
          // all filtered machines have the same vmhost assigned

          // enhance the core summary by the vmhost data
          $('.total-cores').html($('.total-cores').text() + " /<br/> " + $('#machine-table').find('tbody:not(".summary")').find(':hidden').find("td:eq(1):contains('"+vmhost+"')").parent().find('td:eq(4)').text() + " C");
          // enhance the memory summary by the vmhost data
          $('.total-memory').html($('.total-memory').text() + " /<br/> " + $('#machine-table').find('tbody:not(".summary")').find(':hidden').find("td:eq(1):contains('"+vmhost+"')").parent().find('td:eq(5)').text());
          $('.total-diskspace').html($('.total-diskspace').text() + " /<br/> " + $('#machine-table').find('tbody:not(".summary")').find(':hidden').find("td:eq(1):contains('"+vmhost+"')").parent().find('td:eq(6)').text());
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
