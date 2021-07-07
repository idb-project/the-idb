
/* Setup tablesorter. */
$(function () {

  // NOTE: $.tablesorter.theme.bootstrap is ALREADY INCLUDED in the jquery.tablesorter.widgets.js
  // file; it is included here to show how you can modify the default classes
  $.tablesorter.themes.bootstrap = {
    // these classes are added to the table. To see other table classes available,
    // look here: http://getbootstrap.com/css/#tables
    table        : 'table table-bordered table-striped',
    caption      : 'caption',
    // header class names
    header       : 'bootstrap-header', // give the header a gradient background (theme.bootstrap_2.css)
    sortNone     : '',
    sortAsc      : '',
    sortDesc     : '',
    active       : '', // applied when column is sorted
    hover        : '', // custom css required - a defined bootstrap style may not override other classes
    // icon class names
    icons        : '', // add "icon-white" to make them white; this icon class is added to the <i> in the header
    iconSortNone : 'bootstrap-icon-unsorted', // class name added to icon when column is not sorted
    iconSortAsc  : 'fa fa-sort-asc', // class name added to icon when column has ascending sort
    iconSortDesc : 'fa fa-sort-desc', // class name added to icon when column has descending sort
    filterRow    : '', // filter row class; use widgetOptions.filter_cssFilter for the input/select element
    footerRow    : '',
    footerCells  : '',
    even         : '', // even row zebra striping
    odd          : ''  // odd row zebra striping
  };

  var $this = $('#machines-index');

  $("#machine-table").tablesorter({
      theme: 'bootstrap',
      widgets: ['uitheme', 'zebra', 'filter', 'output', 'columnSelector', 'cssStickyHeaders'],
      headerTemplate: '{content} {icon}',
      widgetOptions: {
        filter_reset: null,
        filter_searchDelay: 100,
        filter_filteredRow  : 'filtered',
        output_separator     : ';',         // ',' 'json', 'array' or separator (e.g. ',')
        output_ignoreColumns : [],          // columns to ignore [0, 1,... ] (zero-based index)
        output_dataAttrib    : 'data-name', // data-attribute containing alternate cell text
        output_headerRows    : true,        // output all header rows (multiple rows)
        output_delivery      : 'd',         // (p)opup, (d)ownload
        output_saveRows      : 'f',         // (a)ll, (f)iltered or (v)isible
        output_duplicateSpans: true,        // duplicate output data in tbody colspan/rowspan
        output_replaceQuote  : '\u201c;',   // change quote to left double quote
        output_includeHTML   : false,        // output includes all cell HTML (except the header cells)
        output_trimSpaces    : false,       // remove extra white-space characters from beginning & end
        output_wrapQuotes    : true,       // wrap every cell output in quotes
        output_popupStyle    : 'width=880,height=610',
        output_saveFileName  : 'machine-overview.csv',
        // callbackJSON used when outputting JSON & any header cells has a colspan - unique names required
        output_callbackJSON  : function($cell, txt, cellIndex) { return txt + '(' + cellIndex + ')'; },
        // callback executed when processing completes
        // return true to continue download/output
        // return false to stop delivery & do something else with the data
        output_callback      : function(config, data) { return true; },
        // the need to modify this for Excel no longer exists
        output_encoding      : 'data:application/octet-stream;charset=utf8,',
        // target the column selector markup
        columnSelector_container : $('#columnSelector'),
        // column status, true = display, false = hide
        // disable = do not display on list
        columnSelector_columns : {
          0: false, // ID
        },
        // remember selected columns (requires $.tablesorter.storage)
        columnSelector_saveColumns: true,
        // container layout
        columnSelector_layout : '<label><input type="checkbox">{name}</label>',
        // data attribute containing column name to use in the selector container
        columnSelector_name  : 'data-selector-name',
        /* Responsive Media Query settings */
        // enable/disable mediaquery breakpoints
        columnSelector_mediaquery: false,
        // toggle checkbox name
        columnSelector_mediaqueryName: 'Auto: ',
        // breakpoints checkbox initial setting
        columnSelector_mediaqueryState: true,
        // responsive table hides columns with priority 1-6 at these breakpoints
        // see http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/#Applyingapresetbreakpoint
        // *** set to false to disable ***
        columnSelector_breakpoints : [ '20em', '30em', '40em', '50em', '60em', '70em' ],
        // data attribute containing column priority
        // duplicates how jQuery mobile uses priorities:
        // http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/
        columnSelector_priority : 'data-priority',
        // class name added to checked checkboxes - this fixes an issue with Chrome not updating FontAwesome
        // applied icons; use this class name (input.checked) instead of input:checked
        columnSelector_cssChecked : 'checked',
        cssStickyHeaders_offset        : 40,
        cssStickyHeaders_addCaption    : true,
        // jQuery selector or object to attach sticky header to
        cssStickyHeaders_attachTo      : null,
        cssStickyHeaders_filteredToTop : false,
        cssStickyHeaders_zIndex        : 10
      },
      cssInfoBlock : 'tablesorter-no-sort'
  });

  $("#announcement-machine-table").tablesorter({
    theme: 'bootstrap',
    widgets: ['uitheme', 'zebra', 'filter', 'output', 'columnSelector', 'cssStickyHeaders'],
    headerTemplate: '{content} {icon}',
    widgetOptions: {
      filter_reset: null,
      filter_searchDelay: 100,
      filter_filteredRow  : 'filtered',
      output_separator     : ';',         // ',' 'json', 'array' or separator (e.g. ',')
      output_ignoreColumns : [],          // columns to ignore [0, 1,... ] (zero-based index)
      output_dataAttrib    : 'data-name', // data-attribute containing alternate cell text
      output_headerRows    : true,        // output all header rows (multiple rows)
      output_delivery      : 'd',         // (p)opup, (d)ownload
      output_saveRows      : 'f',         // (a)ll, (f)iltered or (v)isible
      output_duplicateSpans: true,        // duplicate output data in tbody colspan/rowspan
      output_replaceQuote  : '\u201c;',   // change quote to left double quote
      output_includeHTML   : false,        // output includes all cell HTML (except the header cells)
      output_trimSpaces    : false,       // remove extra white-space characters from beginning & end
      output_wrapQuotes    : true,       // wrap every cell output in quotes
      output_popupStyle    : 'width=880,height=610',
      output_saveFileName  : 'machine-overview.csv',
      // callbackJSON used when outputting JSON & any header cells has a colspan - unique names required
      output_callbackJSON  : function($cell, txt, cellIndex) { return txt + '(' + cellIndex + ')'; },
      // callback executed when processing completes
      // return true to continue download/output
      // return false to stop delivery & do something else with the data
      output_callback      : function(config, data) { return true; },
      // the need to modify this for Excel no longer exists
      output_encoding      : 'data:application/octet-stream;charset=utf8,',
      // target the column selector markup
      columnSelector_container : $('#columnSelector'),
      // column status, true = display, false = hide
      // disable = do not display on list
      columnSelector_columns : {
      },
      // remember selected columns (requires $.tablesorter.storage)
      columnSelector_saveColumns: true,
      // container layout
      columnSelector_layout : '<label><input type="checkbox">{name}</label>',
      // data attribute containing column name to use in the selector container
      columnSelector_name  : 'data-selector-name',
      /* Responsive Media Query settings */
      // enable/disable mediaquery breakpoints
      columnSelector_mediaquery: false,
      // toggle checkbox name
      columnSelector_mediaqueryName: 'Auto: ',
      // breakpoints checkbox initial setting
      columnSelector_mediaqueryState: true,
      // responsive table hides columns with priority 1-6 at these breakpoints
      // see http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/#Applyingapresetbreakpoint
      // *** set to false to disable ***
      columnSelector_breakpoints : [ '20em', '30em', '40em', '50em', '60em', '70em' ],
      // data attribute containing column priority
      // duplicates how jQuery mobile uses priorities:
      // http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/
      columnSelector_priority : 'data-priority',
      // class name added to checked checkboxes - this fixes an issue with Chrome not updating FontAwesome
      // applied icons; use this class name (input.checked) instead of input:checked
      columnSelector_cssChecked : 'checked',
      cssStickyHeaders_offset        : 40,
      cssStickyHeaders_addCaption    : true,
      // jQuery selector or object to attach sticky header to
      cssStickyHeaders_attachTo      : null,
      cssStickyHeaders_filteredToTop : false,
      cssStickyHeaders_zIndex        : 10
    },
    cssInfoBlock : 'tablesorter-no-sort'
});

  $(".table").tablesorter({
      theme: 'bootstrap',
      widgets: ['uitheme', 'zebra', 'filter', 'output', 'columnSelector', 'cssStickyHeaders'],
      headerTemplate: '{content} {icon}',
      widgetOptions: {
        filter_reset: null,
        filter_searchDelay: 100,
        filter_filteredRow  : 'filtered',
        output_separator     : ';',         // ',' 'json', 'array' or separator (e.g. ',')
        output_ignoreColumns : [],          // columns to ignore [0, 1,... ] (zero-based index)
        output_dataAttrib    : 'data-name', // data-attribute containing alternate cell text
        output_headerRows    : true,        // output all header rows (multiple rows)
        output_delivery      : 'd',         // (p)opup, (d)ownload
        output_saveRows      : 'f',         // (a)ll, (f)iltered or (v)isible
        output_duplicateSpans: true,        // duplicate output data in tbody colspan/rowspan
        output_replaceQuote  : '\u201c;',   // change quote to left double quote
        output_includeHTML   : false,        // output includes all cell HTML (except the header cells)
        output_trimSpaces    : false,       // remove extra white-space characters from beginning & end
        output_wrapQuotes    : true,       // wrap every cell output in quotes
        output_popupStyle    : 'width=880,height=610',
        output_saveFileName  : 'machine-overview.csv',
        // callbackJSON used when outputting JSON & any header cells has a colspan - unique names required
        output_callbackJSON  : function($cell, txt, cellIndex) { return txt + '(' + cellIndex + ')'; },
        // callback executed when processing completes
        // return true to continue download/output
        // return false to stop delivery & do something else with the data
        output_callback      : function(config, data) { return true; },
        // the need to modify this for Excel no longer exists
        output_encoding      : 'data:application/octet-stream;charset=utf8,',
        // target the column selector markup
        columnSelector_container : $('#columnSelector'),
        // column status, true = display, false = hide
        // disable = do not display on list
        columnSelector_columns : {
          0: 'disabled'
        },
        // remember selected columns (requires $.tablesorter.storage)
        columnSelector_saveColumns: true,
        // container layout
        columnSelector_layout : '<label><input type="checkbox">{name}</label>',
        // data attribute containing column name to use in the selector container
        columnSelector_name  : 'data-selector-name',
        /* Responsive Media Query settings */
        // enable/disable mediaquery breakpoints
        columnSelector_mediaquery: false,
        // toggle checkbox name
        columnSelector_mediaqueryName: 'Auto: ',
        // breakpoints checkbox initial setting
        columnSelector_mediaqueryState: true,
        // responsive table hides columns with priority 1-6 at these breakpoints
        // see http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/#Applyingapresetbreakpoint
        // *** set to false to disable ***
        columnSelector_breakpoints : [ '20em', '30em', '40em', '50em', '60em', '70em' ],
        // data attribute containing column priority
        // duplicates how jQuery mobile uses priorities:
        // http://view.jquerymobile.com/1.3.2/dist/demos/widgets/table-column-toggle/
        columnSelector_priority : 'data-priority',
        // class name added to checked checkboxes - this fixes an issue with Chrome not updating FontAwesome
        // applied icons; use this class name (input.checked) instead of input:checked
        columnSelector_cssChecked : 'checked',
        cssStickyHeaders_offset        : 40,
        cssStickyHeaders_addCaption    : true,
        // jQuery selector or object to attach sticky header to
        cssStickyHeaders_attachTo      : null,
        cssStickyHeaders_filteredToTop : false,
        cssStickyHeaders_zIndex        : 10
      },
      cssInfoBlock : 'tablesorter-no-sort'
  });

    $this.find('.dropdown-toggle').click(function(e){
      // this is needed because clicking inside the dropdown will close
      // the menu with only bootstrap controlling it.
      $this.find('.dropdown-menu').toggle();
      return false;
    });

    // make separator & replace quotes buttons update the value
    $this.find('.output-separator').click(function(){
      $this.find('.output-separator').removeClass('active');
      var txt = $(this).addClass('active').html()
      $this.find('.output-separator-input').val( txt );
      $this.find('.output-filename').val(function(i, v){
        // change filename extension based on separator
        var filetype = (txt === 'json' || txt === 'array') ? 'js' :
          txt === ';' ? 'csv' : 'txt';
        return v.replace(/\.\w+$/, '.' + filetype);
      });
      return false;
    });

    $this.find('.output-quotes').click(function(){
      $this.find('.output-quotes').removeClass('active');
      $this.find('.output-replacequotes').val( $(this).addClass('active').text() );
      return false;
    });

    // clicking the download button; all you really need is to
    // trigger an "output" event on the table
    var $machines = $('#machines-index');
    $this.find('.download').click(function(){
      var typ,
        $table = $machines.find('table'),
        wo = $table[0].config.widgetOptions,
        saved = $machines.find('.output-filter-all :checked').attr('class');
        wo.output_separator    = $machines.find('.output-separator-input').val();
        wo.output_delivery     = $machines.find('.output-download-popup :checked').attr('class') === "output-download" ? 'd' : 'p';
        wo.output_saveRows     = saved === "output-filter" ? 'f' : saved === 'output-visible' ? 'v' : 'a';
        wo.output_replaceQuote = $machines.find('.output-replacequotes').val();
        wo.output_trimSpaces   = $machines.find('.output-trim').is(':checked');
        wo.output_includeHTML  = $machines.find('.output-html').is(':checked');
        wo.output_wrapQuotes   = $machines.find('.output-wrap').is(':checked');
        wo.output_headerRows   = $machines.find('.output-headers').is(':checked');
        wo.output_saveFileName = $machines.find('.output-filename').val();
        $table.trigger('outputTable');
        return false;
    });    

    var $network = $('#networks-show');
    $network.find('.download').click(function(){
      var typ,
        $table = $network.find('.network-table'),
        wo = $table[0].config.widgetOptions,
        saved = $network.find('.output-filter-all :checked').attr('class');
        wo.output_separator    = $network.find('.output-separator-input').val();
        wo.output_delivery     = $network.find('.output-download-popup :checked').attr('class') === "output-download" ? 'd' : 'p';
        wo.output_saveRows     = saved === "output-filter" ? 'f' : saved === 'output-visible' ? 'v' : 'a';
        wo.output_replaceQuote = $network.find('.output-replacequotes').val();
        wo.output_trimSpaces   = $network.find('.output-trim').is(':checked');
        wo.output_includeHTML  = $network.find('.output-html').is(':checked');
        wo.output_wrapQuotes   = $network.find('.output-wrap').is(':checked');
        wo.output_headerRows   = $network.find('.output-headers').is(':checked');
        wo.output_saveFileName = $network.find('.output-filename').val();
        $table.trigger('outputTable');
        return false;
    });

    var $inventory = $('#inventories-index');
    $inventory.find('.download').click(function(){
      var typ,
        $table = $inventory.find('.inventory-table'),
        wo = $table[0].config.widgetOptions,
        saved = $inventory.find('.output-filter-all :checked').attr('class');
        wo.output_separator    = $inventory.find('.output-separator-input').val();
        wo.output_delivery     = $inventory.find('.output-download-popup :checked').attr('class') === "output-download" ? 'd' : 'p';
        wo.output_saveRows     = saved === "output-filter" ? 'f' : saved === 'output-visible' ? 'v' : 'a';
        wo.output_replaceQuote = $inventory.find('.output-replacequotes').val();
        wo.output_trimSpaces   = $inventory.find('.output-trim').is(':checked');
        wo.output_includeHTML  = $inventory.find('.output-html').is(':checked');
        wo.output_wrapQuotes   = $inventory.find('.output-wrap').is(':checked');
        wo.output_headerRows   = $inventory.find('.output-headers').is(':checked');
        wo.output_saveFileName = $inventory.find('.output-filename').val();
        $table.trigger('outputTable');
        return false;
    });

    var $owner = $('#owners-show');
    $owner.find('.download').click(function(){
      var typ,
        $table = $owner.find('#machine-table'),
        wo = $table[0].config.widgetOptions,
        saved = $owner.find('.output-filter-all :checked').attr('class');
        wo.output_separator    = $owner.find('.output-separator-input').val();
        wo.output_delivery     = $owner.find('.output-download-popup :checked').attr('class') === "output-download" ? 'd' : 'p';
        wo.output_saveRows     = saved === "output-filter" ? 'f' : saved === 'output-visible' ? 'v' : 'a';
        wo.output_replaceQuote = $owner.find('.output-replacequotes').val();
        wo.output_trimSpaces   = $owner.find('.output-trim').is(':checked');
        wo.output_includeHTML  = $owner.find('.output-html').is(':checked');
        wo.output_wrapQuotes   = $owner.find('.output-wrap').is(':checked');
        wo.output_headerRows   = $owner.find('.output-headers').is(':checked');
        wo.output_saveFileName = $owner.find('.output-filename').val();
        $table.trigger('outputTable');
        return false;
    });

    $('.tablesorter-headerRow').bind('contextmenu', function(e) {
        e.preventDefault();
    });

});
