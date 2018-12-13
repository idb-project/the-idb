IDB.Views.UsersShow = Backbone.View.extend({
    events: {
        'click .user-delete': 'deleteUser',
        'click .user-delete-ok': 'deleteUserRequest',
        'click .user-delete-cancel': 'hidePopover'
    },

    initialize: function () {
        this.table = new IDB.Views.Table({el: this.$('.tablesorter')});

        this.$deleteLink = $('a.user-delete');

        this.initPopovers();
    },

    initPopovers: function () {
        var view = this;

        view.$deleteLink.popover({
            placement: 'left',
            trigger: 'click',
            html: true,
            content: function () {
                return view.deleteUserConfirm({href: $(this).data('href')});
            }
        });
    },

    deleteUser: function (e) {
        e.preventDefault();
    },

    deleteUserConfirm: _.template(
        '<a class="btn btn-danger user-delete-ok" href="<%= href %>"><i class="fa fa-exclamation-triangle"></i> I\'m sure</a> <button class="btn user-delete-cancel"><i class="fa fa-check"></i> Nope</button>'
    ),

    deleteUserRequest: function (e) {
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

    IDB.dispatch('users:show', function () {
  IDB.usersShow = new IDB.Views.UsersShow({el: $('#users-show')});
});
