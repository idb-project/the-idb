IDB.Views.Flash = Backbone.View.extend({
  initialize: function () {
    var view = this;

    /* Make sure to fade out existing flash messages. */
    if (this.$el.children().length) {
      _.each(this.$el.children(), function (el) {
        (new IDB.Views.FlashMessage({el: el})).fadeOut();
      });
    }

    $('body').on('ajax:success ajax:error', function () {
      view.render();
    });
  },

  render: function () {
    var view = this;

    $.get('/flash').done(function (data) {
      view.renderNotification(data);
    });
  },

  renderNotification: function(data) {
    var flashMessage = new IDB.Views.FlashMessage();

    this.$el.append(flashMessage.render(data));
  }
});

IDB.Views.FlashMessage = Backbone.View.extend({
  tagName: 'div',
  className: 'flash-message',

  initialize: function() {
    this.timeout = this.options.timeout || 2000;
  },

  render: function (data) {
    this.$el.html(data);
    this.fadeOut();

    return this.el;
  },

  fadeOut: function () {
    var view = this;

    if (this.$el.find('.alert-error').length === 0) {
      setTimeout(function () {
        view.$el.fadeOut('slow', function () {
          $(this).remove();
        });
      }, this.timeout);
    }
  }
});
