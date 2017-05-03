// returns a function object which sets a dropdown to the option which has the given id as value.
function set_location_for(control_id) {
  f = function set_location(id) {
      selectObj = document.getElementById(control_id);
      for (var i = 0; i < selectObj.options.length; i++) {
          if (selectObj.options[i].value == id) {
              selectObj.options[i].selected = true;
              return;
          };
      };
  };
  return f;
};