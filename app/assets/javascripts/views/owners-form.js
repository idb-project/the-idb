IDB.Views.OwnersForm = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    this.markupPreview = new IDB.Views.MarkupPreview({el: this.$el});

    this.markupPreview.trigger('render');
  },
});

IDB.dispatch('owners:new owners:edit', function () {
  IDB.ownersForm = new IDB.Views.OwnersForm({el: $('#owners-form')});
});
