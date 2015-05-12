
var zss_extend = {};

zss_extend.insertImage = function (url, alt) {
    var image = new Image();
    alt = alt || "";
    image.src = url;
    if (image.complete) {
        __onload__();
    }
    else {
        image.onload = __onload__;
    }
    
    function __onload__() {
        var width = image.width;
        if (width >= $("#zss_editor_content").width()) {
            zss_extend.insertImageWithClass(url, alt, "fullscreen");
        }
        else {
            zss_extend.insertImageWithClass(url, alt, "a");
        }
        image = null;
    };
}


zss_extend.insertImageWithClass = function(url, alt, klass) {
    zss_editor.restorerange();
    var html = '<img src="'+url+'" alt="'+alt+' "class="'+klass+'" />';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}