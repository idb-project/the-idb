IDB.Views.NetworksIndex = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    this.table = new IDB.Views.Table({el: this.$('.tablesorter')});
  },
});

IDB.dispatch('networks:index', function () {
  IDB.networksIndex = new IDB.Views.NetworksIndex({el: $('#networks-index')});
});
