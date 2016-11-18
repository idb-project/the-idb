IDB.Views.MachinesIndex = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    this.table = new IDB.Views.Table({el: this.$('.tablesorter')});
  },
});

IDB.dispatch('machines:index', function () {
  IDB.machinesIndex = new IDB.Views.MachinesIndex({el: $('#machines-index')});
});
