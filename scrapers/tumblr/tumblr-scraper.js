var url = 'https://fuckinganaling.tumblr.com/archive';

var page = require('webpage').create();
page.open(url, function() {
    console.log(page.content);
    phantom.exit();
});
