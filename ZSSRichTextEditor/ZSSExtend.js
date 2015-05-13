
var zss_extend = {};

zss_extend.insertImage = function (url, alt) {
    zss_editor.debug('insert');
    var image = new Image();
    alt = alt || "";
    image.src = url;
    if (image.complete) {
        __onload__();
    }
    else {
        image.onload = __onload__;
    }
//    zss_editor.debug('insert');
    function __onload__() {
        var width = image.width;
        if (width >= $("#zss_editor_content").width()) {
            zss_extend.insertImageWithClass(url, alt, true);
        } else {
            zss_extend.insertImageWithClass(url, alt, false);
        }
        image = null;
    };
}


zss_extend.insertImageWithClass = function(url, alt, scale) {
    zss_editor.restorerange();
//    zss_editor.debug(scale);
    var html = '';
    if (scale) {
        html = '<img src="'+url+'" alt="'+alt+'" style="width: 100%; box-sizing: border-box;" />';
    } else {
        html = '<img src="'+url+'" alt="'+alt+'"/>';
    }
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

zss_extend.showRange = function() {
    alert(document.getSelection().toString());
}
