
var zss_extend = {};

zss_extend.insertImage = function (url, alt) {
    
    var range;
    var select;
    var nextNode;
    var html = '<img src="'+url+'" alt="'+alt+'" style="display:table; max-width:100%;"/>';
    
//    zss_editor.restorerange();
    
    select = window.getSelection();
    if ( document.TEXT_NODE == select.baseNode.nodeType) {
        html = "<div>" + html + "</div>";
    }
//    alert(html);
    
    zss_editor.insertHTML(html);
    
    range = window.getSelection().getRangeAt(0);
    nextNode = range.endContainer.nextSibling;
    
    console.log(range, nextNode);
    
    if (nextNode) {
        zss_editor.currentSelection = {
            "startContainer": nextNode,
            "startOffset": 0,
            "endContainer": nextNode,
            "endOffset": 0
        };
//        zss_editor.restorerange();
    }
    else {
        html = "<div><br/></div> <div><br/></div>";
//        alert("<div><br></div>");
        zss_editor.insertHTML(html);
    }
    
    zss_editor.enabledEditingItems();
}


/*
zss_extend.insertImage = function (url, alt) {
    zss_editor.restorerange();
//    </br></br></br>
    var html = '<img src="'+url+'" alt="'+alt+'" style="display:block; max-width:100%;"/> <div></br></div> <div></br></div>';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
//    zss_extend.restorerange();
//    zss_editor.focusEditor();
}
*/
/*
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
*/
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

zss_extend.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(zss_editor.currentSelection.startContainer, zss_editor.currentSelection.startOffset);
    range.setEnd(zss_editor.currentSelection.endContainer, zss_editor.currentSelection.endOffset);
    selection.addRange(range);
}

