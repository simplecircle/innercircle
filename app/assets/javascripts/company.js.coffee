$(document).ready ->
  companyHandler = null
  companyOptions =
    itemWidth: 450
    autoResize: true
    container: $('#company > #collection')
    offset: 15
    flexibleWidth: 550

  companyHandler = $('#company > #collection li');
  companyHandler.wookmark(companyOptions);