IDB.Views.OwnersShow = Backbone.View.extend({
    events: {
        'click .owner-delete': 'deleteOwner',
        'click .owner-delete-ok': 'deleteOwnerRequest',
        'click .owner-delete-cancel': 'hidePopover'
    },

    initialize: function () {
        this.table = new IDB.Views.Table({el: this.$('.tablesorter')});

        this.$deleteLink = $('a.owner-delete');

        this.initPopovers();
    },

    initPopovers: function () {
        var view = this;

        view.$deleteLink.popover({
            placement: 'left',
            trigger: 'click',
            html: true,
            content: function () {
                return view.deleteOwnerConfirm({href: $(this).data('href')});
            }
        });
    },

    deleteOwner: function (e) {
        e.preventDefault();
    },

    deleteOwnerConfirm: _.template(
        '<a class="btn btn-danger owner-delete-ok" href="<%= href %>"><i class="fa fa-exclamation-triangle"></i> I\'m sure</a> <button class="btn owner-delete-cancel"><i class="fa fa-check"></i> Nope</button>'
    ),

    deleteOwnerRequest: function (e) {
        var view = this;

        e.preventDefault();

        $.ajax({
            url: $(e.target).attr('href'),
            type: 'DELETE'
        }).done(function (data) {
            window.location = data.redirectTo;
        });
    },

    hidePopover: function (e) {
        this.$deleteLink.popover('hide');
    },
});

    IDB.dispatch('owners:show', function () {
  IDB.ownersShow = new IDB.Views.OwnersShow({el: $('#owners-show')});
});
