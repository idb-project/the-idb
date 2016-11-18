IDB.Views.MachinesForm = Backbone.View.extend({
  events: {
  },

  initialize: function () {
    this.markupPreview = new IDB.Views.MarkupPreview({el: this.$el});
    this.detailsForm = new IDB.Views.MachinesDetailsForm({el: this.$('.machines-details-form')});

    this.markupPreview.trigger('render');
  },
});

IDB.dispatch('machines:new machines:edit', function () {
  IDB.machinesForm = new IDB.Views.MachinesForm({el: $('#machines-form')});
});
