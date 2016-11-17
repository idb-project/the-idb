IDB.Views.NetworksShow = Backbone.View.extend({
  events: {
    'click .network-delete': 'deleteNetwork',
    'click .network-delete-ok': 'deleteNetworkRequest',
    'click .network-delete-cancel': 'hidePopover'
  },

  initialize: function () {
    this.table = new IDB.Views.Table({el: this.$('.tablesorter')});
    this.$deleteLink = $('a.network-delete');

    this.initPopovers();
  },

  initPopovers: function () {
    var view = this;

    view.$deleteLink.popover({
      placement: 'left',
      trigger: 'click',
      html: true,
      content: function () {
        return view.deleteNetworkConfirm({href: $(this).data('href')});
      }
    });
  },

  deleteNetwork: function(e) { e.preventDefault(); },

  deleteNetworkConfirm: _.template(
    '<a class="btn btn-danger network-delete-ok" href="<%= href %>"><i class="fa fa-exclamation-triangle"></i> I\'m sure</a> <button class="btn network-delete-cancel"><i class="fa fa-check"></i> Nope</button>'
  ),

  deleteNetworkRequest: function (e) {
    var view = this;

    e.preventDefault();

    $.ajax({
      url: $(e.target).attr('href'),
      type: 'DELETE'
    }).done(function (data) {
      window.location = data.redirectTo;
    });
  },

  hidePopover: function (e) {
    this.$deleteLink.popover('hide');
  }
});

IDB.dispatch('networks:show', function () {
  IDB.networksShow = new IDB.Views.NetworksShow({el: $('#networks-show')});
});

$(function() {
  $("#toggle_ips").click(function() {
    $(".hide_ip").toggle();
    if ($("#toggle_ips").prop("checked")) {
      $("#ip_addresses_table .tablesorter-filter").prop("disabled", true);
    } else {
      $("#ip_addresses_table .tablesorter-filter").prop("disabled", false);
    }
  });
});
