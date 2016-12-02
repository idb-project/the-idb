/* Setup namespace for backbone. */
window.IDB = {
  Models: {},
  Collections: {},
  Views: {},
  Dispatch: _.clone(Backbone.Events),
  dispatch: function (event, callback) {
    var events = _.map(event.split(/\s+/), function (e) {
      return 'dispatch:' + e;
    }).join(' ');

    IDB.Dispatch.on(events, callback);
  }
};

/* Setup global code and dispatch controller/action events. */
$(function () {
  var controller = $('body').data('controller'),
      action = $('body').data('action');

  IDB.flash = new IDB.Views.Flash({el: $('#flash')});

  IDB.Dispatch.trigger('dispatch:' + controller);
  IDB.Dispatch.trigger('dispatch:' + controller + ':' + action);
});
