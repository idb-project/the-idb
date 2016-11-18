IDB.Views.OutdatedMachinesIndex = Backbone.View.extend({
  events: {
    'click .machine-delete': 'deleteMachine',
    'click .machine-delete-ok': 'deleteMachineRequest',
    'click .machine-delete-cancel': 'hidePopover'
  },

  initialize: function () {
    this.$deleteLink = $('a.machine-delete');

    this.initPopovers();
  },

  initPopovers: function () {
    var view = this;

    view.$deleteLink.popover({
      placement: 'left',
      trigger: 'click',
      html: true,
      content: function () {
        return view.deleteMachineConfirm({href: $(this).data('href')});
      }
    });
  },

  deleteMachine: function(e) { e.preventDefault(); },

  deleteMachineConfirm: _.template(
    '<a class="btn btn-danger machine-delete-ok" href="<%= href %>"><i class="fa fa-exclamation-triangle"></i> I\'m sure</a> <button class="btn machine-delete-cancel"><i class="fa fa-check"></i> Nope</button>'
  ),

  deleteMachineRequest: function (e) {
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
  },

});

IDB.dispatch('outdated-machines:index', function () {
    IDB.outdatedMachinesIndex = new IDB.Views.OutdatedMachinesIndex({el: $('#outdated-machines-index')});
});
