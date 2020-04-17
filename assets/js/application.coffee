siteWidth = 1280;
scale = screen.width /siteWidth
document.querySelector('meta[name="viewport"]').setAttribute('content', 'width='+siteWidth+', initial-scale='+scale+'')
$('.dropdown-toggle').dropdown()

$(document).ready ->
  setTimeout (->
    $('#flash').fadeOut()
    return
  ), 2000
  return