IDB.Views.OwnersIndex = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    this.table = new IDB.Views.Table({el: this.$('.tablesorter')});
  },
});

IDB.dispatch('owners:index', function () {
  IDB.ownersIndex = new IDB.Views.OwnersIndex({el: $('#owners-index')});
});
