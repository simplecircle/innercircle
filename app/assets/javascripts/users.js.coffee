
$(document).ready ->
  data = [
    {name: "Mick Jagger"},
    {name: "Johnny Storm"},
    {name: "Richard Hatch"},
    {name: "Kelly Slater"},
    {name: "Rudy Hamilton"},
    {name: "Michael Jordan"}
  ];
  $("#skills").autoSuggest data,
    selectedItemProp: "name"
    searchObjProps: "name"

