siteWidth = 1280;
scale = screen.width /siteWidth
document.querySelector('meta[name="viewport"]').setAttribute('content', 'width='+siteWidth+', initial-scale='+scale+'')