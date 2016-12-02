IDB.Views.MarkupPreview = Backbone.View.extend({
  events: {
    'keyup #markup-source': 'renderDelayedPreview',
    'change #markup-source': 'renderDelayedPreview'
  },

  initialize: function () {
    this.$source = this.$('#markup-source');
    this.$target = this.$('.markup-target');

    this.timeout = 1000;
    this.timerRunning = false;

    this.on('render', this.renderPreview, this);
  },

  render: function () {
    var view = this;

    IDB.Utils.renderMarkupPreview(this.$source.val(), function (data) {
      if (data.length) {
        view.$target.html(data);
      } else {
        view.$target.html('empty description ...');
      }

      /* Only reset the flag once we updated the preview target. */
      view.timerRunning = false;
    });
  },

  renderPreview: function (e) {
    if (e) { e.preventDefault(); }

    this.render();
  },

  renderDelayedPreview: function (e) {
    var view = this;

    /* Start a new timer if none is running. */
    if (!this.timerRunning) {
      /* First set the flag so we do not start another timer. */
      view.timerRunning = true;

      /* Fire the render function after a timeout. This avoids hammering the
       * server with markup rendering requests. */
      setTimeout(function () {
        view.render();
      }, this.timeout);
    }
  }
});
