IDB.Views.NetworksForm = Backbone.View.extend({
  events: {
    'click .toggle-allowed-ip-addresses': 'toggleAllowedIpAddresses'
  },

  initialize: function () {
    this.markupPreview = new IDB.Views.MarkupPreview({el: this.$el});

    this.markupPreview.trigger('render');
  },

  toggleAllowedIpAddresses: function (e) {
    e.preventDefault();

    this.$('.allowed-ip-addresses').toggle();
  }
});

IDB.dispatch('networks:new networks:edit', function () {
  IDB.networksForm = new IDB.Views.NetworksForm({el: $('#networks-form')});
});
