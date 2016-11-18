IDB.Views.MachinesDetailsForm = Backbone.View.extend({
  events: {
    'click .machine-add-network-interface': 'addNicTemplate',
    'click .machine-add-alias': 'addAliasTemplate'
  },

  initialize: function () {
    this.$interfacesContainer = this.$('.machine-network-interfaces');
    this.$interfaceTemplate = this.$('.machine-network-interfaces-template');
    this.$aliasesContainer = this.$('.machine-aliases');
    this.$aliasesTemplate = this.$('.machine-alias-template');
  },

  addNicTemplate: function (e) {
    e.preventDefault();

    this.$interfacesContainer.append(this.$interfaceTemplate.html());
  },

  addAliasTemplate: function (e) {
    e.preventDefault();

    this.$aliasesContainer.append(this.$aliasesTemplate.html());
  }
});
