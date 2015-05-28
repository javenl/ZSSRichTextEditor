
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

zss_extend.insertMP3 = function(url) {
    zss_editor.restorerange();
    
    var html =
    '<div style="text-align: center;" width="100%">'+
    '<audio controls="controls">'+
    '<source src="'+url+'" type="audio/mp3"/>'+
    '暂不支持该格式'+
    '</audio>'+
    '</div>';
    
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

zss_extend.insertVideo = function(url) {
    zss_editor.restorerange();
    
    var html =
    '<video controls="controls" width="100%" style="text-align: center;">'+
    '<source src="'+url+'" type="video/mp4"/>'+
    '暂不支持该格式'+
    '</video>';
    
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

zss_extend.getAllImageLinks = function() {
    var array = [];
    var s = "";
    $("img").each(function (index, el) {
                  
        array.push(el.src);
//                  if (s != "") {
//                  s += el.src;
//                  } else {
//                  s += "," + el.src;
//                  }
    });

    return JSON.stringify(array);
}

