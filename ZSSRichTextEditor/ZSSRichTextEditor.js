/*!
 *
 * ZSSRichTextEditor v0.5.2
 * http://www.zedsaid.com
 *
 * Copyright 2014 Zed Said Studio LLC
 *
 */

var zss_editor = {};

// If we are using iOS or desktop
zss_editor.isUsingiOS = true;

// If the user is draging
zss_editor.isDragging = false;

// The current selection
zss_editor.currentSelection;

// The current editing image
zss_editor.currentEditingImage;

// The current editing link
zss_editor.currentEditingLink;

// The objects that are enabled
zss_editor.enabledItems = {};

// Height of content window, will be set by viewController
zss_editor.contentHeight = 180;// 180; // 244;

// Sets to true when extra footer gap shows and requires to hide
zss_editor.updateScrollOffset = false;

zss_editor.needToScroll = true;

/**
 * The initializer function that must be called onLoad
 */
zss_editor.init = function() {
    $('#zss_editor_content')
    .on('touchend', function(e) {
                                zss_editor.enabledEditingItems(e);
//                                var clicked = $(e.target);
//                                if (!clicked.hasClass('zs_active')) {
//                                $('img').removeClass('zs_active');
//                                }
                                })
    .on('input', function (e) {
        zss_editor.calculateEditorHeightWithCaretPosition(e);
        zss_editor.setScrollPosition();
        zss_extend.enabledEditingItems(e);
        // e.stopPropagation();
        // console.log(document.body.scrollTop);
    });
    
    $(document).on('selectionchange',function(e){
//                   if (zss_editor.needToScroll) {
                       zss_editor.calculateEditorHeightWithCaretPosition(e);
                       zss_editor.setScrollPosition();
//                   }
                   zss_extend.enabledEditingItems(e);
//                   zss_editor.debug("change");
//                   if (editor.is(":focus")) {
//                       ZSSEditor.selectionChangedCallback();
//                       ZSSEditor.sendEnabledStyles(e);
                   
//                       var clicked = $(e.target);
//                       if (!clicked.hasClass('zs_active')) {
//                           $('img').removeClass('zs_active');
//                       }
//                   }
                   
                   });
    
    $(window).on('scroll', function(e) {
                 zss_editor.updateOffset();
                 });
    
    // Make sure that when we tap anywhere in the document we focus on the editor
    
    $(window).on('touchmove', function(e) {
                 zss_editor.isDragging = true;
                 zss_editor.updateScrollOffset = true;
                 zss_editor.setScrollPosition();
                 });
    
    
    $(window).on('touchstart', function(e) {
                 zss_editor.isDragging = false;
//                 zss_editor.needToScroll = false;
                 zss_editor.calculateEditorHeightWithCaretPosition;
                 });
    
    $(window).on('touchend', function(e) {
                 // console.log(e);
//                 zss_editor.needToScroll = true;
                 var t = $(e.target);
                 var nodeName = e.target.nodeName.toLowerCase();
                 if (nodeName == "html") {
                     //点击任何地方都可以进入编辑
                     if (!zss_editor.isDragging) {
                        zss_editor.focusEditor();
                     }
                 }
                 });
    
    // @add
//    document.execCommand('formatBlock', false, 'div');

}//end

zss_editor.updateOffset = function() {
    
    if (!zss_editor.updateScrollOffset)
        return;
    
    var offsetY = window.document.body.scrollTop;
    
    var footer = $('#zss_editor_footer');
    
    var maxOffsetY = footer.offset().top - zss_editor.contentHeight;
    
    if (maxOffsetY < 0)
        maxOffsetY = 0;
    
    if (offsetY > maxOffsetY)
    {
        window.scrollTo(0, maxOffsetY);
    }
    
    zss_editor.setScrollPosition();
}

// This will show up in the XCode console as we are able to push this into an NSLog.
zss_editor.debug = function(msg) {
    window.location = 'debug://'+msg;
    console.log('debug://'+msg);
}


zss_editor.setScrollPosition = function() {
//    var position = window.pageYOffset;
//    window.location = 'scroll://'+position;
}


zss_editor.setPlaceholder = function(placeholder) {
    
    var editor = $('#zss_editor_content');
    
    //set placeHolder
    if(editor.text().length == 1){
        editor.text(placeholder);
        editor.css("color","gray");
    }
    //set focus
    editor.focus(function(){
                 if($(this).text() == placeholder){
                 $(this).text("");
                 $(this).css("color","black");
                 }
                 }).focusout(function(){
                             if(!$(this).text().length){
                             $(this).text(placeholder);
                             $(this).css("color","gray");
                             }
                             });
    
}

zss_editor.setFooterHeight = function(footerHeight) {
    var footer = $('#zss_editor_footer');
    footer.height(footerHeight + 'px');
}

zss_editor.getCaretYPosition = function(e) {
    // console.log( window.getSelection().anchorNode.data ||
    //              window.getSelection().anchorNode.parentNode.innerHTML );
    try {
        var sel = window.getSelection();
        // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
        //sel.collapseToStart();
        var range  = sel.getRangeAt(0);
        var rangeRects = range.getClientRects();
        var scrollTop = window.document.body.scrollTop;
        var topPosition = 0;
        
        if (rangeRects.length) {
            topPosition = scrollTop + rangeRects[0].top;
        }
        else {
            var span = document.createElement('span');// something happening here preventing selection of elements
            range.insertNode(span);
            topPosition = span.offsetTop;
            span.parentNode.removeChild(span);
        }
        
//        setInterval(function () {
//                    console.log("test");
//                    }, 1000);
        // console.log(topPosition);
//        zss_editor.debug(topPosition);
        return topPosition;
        
    }
    catch (err) {
        setTimeout(function () {
                   zss_editor.debug(err.message);
                   });
        return window.document.body.scrollTop;
    }
    

    
    /*
    var sel = window.getSelection();
    var baseNode = sel.baseNode;
    var pos;
    
    if (sel && baseNode) {
        // 当选中的节点为文本节点时，取其父节点的offsetTop，否则取自身的offsetTop
        pos = 3 == baseNode.nodeType
        ? baseNode.parentNode.offsetTop
        : baseNode.offsetTop;
    }
    else {
        pos = document.body.scrollTop;
    }
    
    return pos + 64;
    */
    /*
    var sel = window.getSelection();
    // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
//    sel.collapseToStart();
    var range = sel.getRangeAt(0);
    var span = document.createElement('span');// something happening here preventing selection of elements
    range.insertNode(span);
    var topPosition = span.offsetTop;
    span.parentNode.removeChild(span);
    return topPosition;
    */
    /*
    try {
        var sel = window.getSelection();
        // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
        //sel.collapseToStart();
        var range = sel.getRangeAt(0);
        zss_editor.debug('!!!:');
//        var span = document.createElement('span');// something happening here preventing selection of elements
//        range.insertNode(span);
//        var topPosition = span.offsetTop;
//        span.parentNode.removeChild(span);
//        return topPosition;
    }
    catch (e) {
        zss_editor.debug(e.message);
    }
    return 0;
    */
}

zss_editor.calculateEditorHeightWithCaretPosition = function(e) {
    
    var padding = 50;
    var c = zss_editor.getCaretYPosition(e);
//    var c = 0;
    var e = document.getElementById('zss_editor_content');
    
    var editor = $('#zss_editor_content');
    
    var offsetY = window.document.body.scrollTop;
    var height = zss_editor.contentHeight;
    
    var newPos = window.pageYOffset;
    
    if (c < offsetY) {
        newPos = c;
    } else if (c > (offsetY + height - padding)) {
        var newPos = c - height + padding - 18;
    }
    
    // setTimeout(function () {
    //            window.scrollTo(0, newPos);
    //            console.log(newPos, document.body.scrollTop);
    //            }, 1000);
    window.scrollTo(0, newPos);
    console.log(newPos, document.body.scrollTop);
}

zss_editor.backuprange = function(){
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    zss_editor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

zss_editor.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(zss_editor.currentSelection.startContainer, zss_editor.currentSelection.startOffset);
    range.setEnd(zss_editor.currentSelection.endContainer, zss_editor.currentSelection.endOffset);
    selection.addRange(range);
}

zss_editor.getSelectedNode = function() {
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
    if (node) {
        return (node.nodeName == "#text" ? node.parentNode : node);
    }
};

zss_editor.setBold = function() {
    document.execCommand('bold', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setItalic = function() {
    document.execCommand('italic', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSubscript = function() {
    document.execCommand('subscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSuperscript = function() {
    document.execCommand('superscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setUnderline = function() {
    document.execCommand('underline', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
    zss_editor.enabledEditingItems();
}

zss_editor.removeFormating = function() {
    document.execCommand('removeFormat', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setHorizontalRule = function() {
    document.execCommand('insertHorizontalRule', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setHeading = function(heading) {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_heading = (t == 'h1' || t == 'h2' || t == 'h3' || t == 'h4' || t == 'h5' || t == 'h6');
    if (is_heading && heading == t) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<'+heading+'>');
    }
    
    zss_editor.enabledEditingItems();
}

zss_editor.setParagraph = function() {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_paragraph = (t == 'p');
    if (is_paragraph) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<p>');
    }
    
    zss_editor.enabledEditingItems();
}

// Need way to remove formatBlock
console.log('WARNING: We need a way to remove formatBlock items');

zss_editor.undo = function() {
    document.execCommand('undo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.redo = function() {
    document.execCommand('redo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOrderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "") { // 移除节点
        document.execCommand('insertOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "UL" ) { //插入或更改节点
            document.execCommand('insertOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.removeAttribute("type");//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setUpCharOrderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "A") { // 移除节点
        document.execCommand('insertOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "UL" ) { //插入或更改节点
            document.execCommand('insertOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "A";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setLowCharOrderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "a") { // 移除节点
        document.execCommand('insertOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "UL" ) { //插入或更改节点
            document.execCommand('insertOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "a";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setUpRomanOrderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "I") { // 移除节点
        document.execCommand('insertOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "UL" ) { //插入或更改节点
            document.execCommand('insertOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "I";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setLowRomanOrderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "i") { // 移除节点
        document.execCommand('insertOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "UL" ) { //插入或更改节点
            document.execCommand('insertOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "i";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setUnorderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "") { // 移除节点
        document.execCommand('insertUnOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "OL" ) { //插入或更改节点
            document.execCommand('insertUnOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.removeAttribute("type");//更改类型
    }
    
    zss_editor.enabledEditingItems();
}

zss_editor.setSquareUnorderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "square") { // 移除节点
        document.execCommand('insertUnOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "OL" ) { //插入或更改节点
            document.execCommand('insertUnOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "square";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setCircleUnorderedList = function() {
    var node = zss_extend.closerListNode();
    if (node != null && node.type == "circle") { // 移除节点
        document.execCommand('insertUnOrderedList', false, null);
    } else {
        if (node == null || node.nodeName == "OL" ) { //插入或更改节点
            document.execCommand('insertUnOrderedList', false, null);
            node = zss_extend.closerListNode();//重新获取节点
        }
        node.type = "circle";//更改类型
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyFull = function() {
    document.execCommand('justifyFull', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setQuote = function() {
    var node = zss_extend.closerBlockQuoteNode();
    if (node == null) {
        document.execCommand('formatBlock', false, '<blockquote>');
        node = zss_extend.closerBlockQuoteNode();
        node.setAttribute('style', 'border-left: 5px solid #eeeeee; margin:0; padding-left:20px;');
    } else {
        document.execCommand('outdent', false, null);
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setIndent = function() {
    document.execCommand('indent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOutdent = function() {
    document.execCommand('outdent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setParagraphTop = function(top) {
    var node = zss_extend.closerDivOrP();
    if (node) {
        $(node).css('margin-top', top+'px');
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setParagraphBottom = function(bottom) {
    var node = zss_extend.closerDivOrP();
    if (node) {
        $(node).css('margin-bottom', bottom+'px');
    }
    zss_editor.enabledEditingItems();
}

zss_editor.setFontSize = function(fontSize) {
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('FontSize', false, 1);
    document.execCommand("styleWithCSS", null, false);
    var node = zss_editor.closerParentNode();
    $(node).css('font-size', fontSize+"px");
    ZSSEditor.sendEnabledStyles();
}

zss_editor.setTextColor = function(color) {
//    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor
}

zss_editor.setBackgroundColor = function(color) {
//    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
}

// Needs addClass method

zss_editor.insertLink = function(url, title) {
    
    zss_editor.restorerange();
    var sel = document.getSelection();
    console.log(sel);
    if (sel.toString().length != 0) {
        if (sel.rangeCount) {
            
            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);
            
            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    zss_editor.enabledEditingItems();
}

zss_editor.updateLink = function(url, title) {
    
    zss_editor.restorerange();
    
    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.attr('href', url);
        c.attr('title', title);
    }
    zss_editor.enabledEditingItems();
    
}//end

zss_editor.updateImage = function(url, alt) {
    
    zss_editor.restorerange();
    
    if (zss_editor.currentEditingImage) {
        var c = zss_editor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    zss_editor.enabledEditingItems();
    
}//end

zss_editor.unlink = function() {
    
    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.contents().unwrap();
    }
    zss_editor.enabledEditingItems();
}

zss_editor.quickLink = function() {
    
    var sel = document.getSelection();
    var link_url = "";
    var test = new String(sel);
    var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
    if (test.search(mailregexp) == -1) {
        checkhttplink = new RegExp("^http\:\/\/", "gi");
        if (test.search(checkhttplink) == -1) {
            checkanchorlink = new RegExp("^\#", "gi");
            if (test.search(checkanchorlink) == -1) {
                link_url = "http://" + sel;
            } else {
                link_url = sel;
            }
        } else {
            link_url = sel;
        }
    } else {
        checkmaillink = new RegExp("^mailto\:", "gi");
        if (test.search(checkmaillink) == -1) {
            link_url = "mailto:" + sel;
        } else {
            link_url = sel;
        }
    }
    
    var html_code = '<a href="' + link_url + '">' + sel + '</a>';
    zss_editor.insertHTML(html_code);
    
}

zss_editor.prepareInsert = function() {
    zss_editor.backuprange();
}

zss_editor.insertImage = function(url, alt) {
    zss_editor.restorerange();
    var html = '<img src="'+url+'" alt="'+alt+'" width="100%"/>';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

zss_editor.setHTML = function(html) {
    var editor = $('#zss_editor_content');
    editor.html(html);
}

zss_editor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    zss_editor.enabledEditingItems();
}

zss_editor.getHTML = function() {
    
    // Images
    var img = $('img');
    if (img.length != 0) {
        $('img').removeClass('zs_active');
        $('img').each(function(index, e) {
                      var image = $(this);
                      var zs_class = image.attr('class');
                      if (typeof(zs_class) != "undefined") {
                      if (zs_class == '') {
                      image.removeAttr('class');
                      }
                      }
                      });
    }
    
    // Blockquote
    var bq = $('blockquote');
    if (bq.length != 0) {
        bq.each(function() {
                var b = $(this);
                if (b.css('border').indexOf('none') != -1) {
                b.css({'border': ''});
                }
                if (b.css('padding').indexOf('0px') != -1) {
                b.css({'padding': ''});
                }
                });
    }
    
    // Get the contents
    var h = document.getElementById("zss_editor_content").innerHTML;
    
    return h;
}

zss_editor.getText = function() {
    return $('#zss_editor_content').text();
}

zss_editor.isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
}

zss_editor.detactStyle = function() {
    var items = [];
    if (zss_editor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (zss_editor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (zss_editor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (zss_editor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (zss_editor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (zss_editor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (zss_editor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (zss_editor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (zss_editor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (zss_editor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (zss_editor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (zss_editor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (zss_editor.isCommandEnabled('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    if (items.length > 0) {
        return items.join(',');
    } else {
        return '';
    }
}

zss_editor.enabledEditingItems = function(e) {
    
//    zss_editor.debug('enabledEditingItems');
//    console.log('enabledEditingItems');
    var items = [];
    if (zss_editor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (zss_editor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (zss_editor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (zss_editor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (zss_editor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (zss_editor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (zss_editor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (zss_editor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (zss_editor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (zss_editor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (zss_editor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (zss_editor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (zss_editor.isCommandEnabled('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    // Images
//    $('img').bind('touchstart', function(e) {
//                  $('img').removeClass('zs_active');
//                  $(this).addClass('zs_active');
//                  });
    
    // Use jQuery to figure out those that are not supported
    if (typeof(e) != "undefined") {
        
        // The target element
        var t = $(e.target);
        var nodeName = e.target.nodeName.toLowerCase();
        
        // Background Color
        
        var bgColor = t.css('backgroundColor');
        if (bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
            bgColor = zss_extend.RGBToHex(bgColor);
            items.push('backgroundColor:'+bgColor);
        }
        // Text Color
        var textColor = t.css('color');
        if (textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
            textColor = zss_extend.RGBToHex(textColor);
            items.push('textColor:'+textColor);
        }
        
        // Link
        if (nodeName == 'a') {
            zss_editor.currentEditingLink = t;
            var title = t.attr('title');
            items.push('link:'+t.attr('href'));
            if (t.attr('title') !== undefined) {
                items.push('link-title:'+t.attr('title'));
            }
            
        } else {
            zss_editor.currentEditingLink = null;
        }
        // Blockquote
        if (nodeName == 'blockquote') {
            items.push('indent');
        }
        // Image
        if (nodeName == 'img') {
            zss_editor.currentEditingImage = t;
            items.push('image:'+t.attr('src'));
            if (t.attr('alt') !== undefined) {
                items.push('image-alt:'+t.attr('alt'));
            }
            
        } else {
            zss_editor.currentEditingImage = null;
        }
        
    }
    
//    zss_editor.isUsingiOS = false;
    if (items.length > 0) {
        if (zss_editor.isUsingiOS) {
//            window.location = "zss-callback/"+items.join(',');
            window.location = "callback://0/"+items.join(',');
        } else {
            console.log("callback://"+items.join(','));
        }
    } else {
        if (zss_editor.isUsingiOS) {
//            window.location = "zss-callback/";
        } else {
            console.log("callback://");
        }
    }
    return items;
}

zss_editor.focusEditor = function() {
    
    // the following was taken from http://stackoverflow.com/questions/1125292/how-to-move-cursor-to-end-of-contenteditable-entity/3866442#3866442
    // and ensures we move the cursor to the end of the editor
    var editor = $('#zss_editor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
//    alert(editor);
    editor.focus();
}

zss_editor.blurEditor = function() {
    $('#zss_editor_content').blur();
}//end


