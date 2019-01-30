/*
 Copyright (c) 2003-2017, CKSource - Frederico Knabben. All rights reserved.
 For licensing, see LICENSE.md or http://ckeditor.com/license
*/
!function(){function t(){return!1}function e(t,e){var r,i=[];for(t.filterChildren(e),r=t.children.length-1;0<=r;r--)i.unshift(t.children[r]),t.children[r].remove();r=t.attributes;var s,n=t,a=!0;for(s in r)if(a)a=!1;else{var l=new CKEDITOR.htmlParser.element(t.name);l.attributes[s]=r[s],n.add(l),n=l,delete r[s]}for(r=0;r<i.length;r++)n.add(i[r])}var r,i,s,n,a=CKEDITOR.tools,l=["o:p","xml","script","meta","link"],o={},c=0;CKEDITOR.plugins.pastefromword={},CKEDITOR.cleanWord=function(u,m){var f=Boolean(u.match(/mso-list:\s*l\d+\s+level\d+\s+lfo\d+/));CKEDITOR.plugins.clipboard.isCustomDataTypesSupported&&(u=CKEDITOR.plugins.pastefromword.styles.inliner.inline(u).getBody().getHtml()),u=u.replace(/<!\[/g,"<!--[").replace(/\]>/g,"]-->");var d=CKEDITOR.htmlParser.fragment.fromHtml(u);n=new CKEDITOR.htmlParser.filter({root:function(t){t.filterChildren(n),CKEDITOR.plugins.pastefromword.lists.cleanup(r.createLists(t))},elementNames:[[/^\?xml:namespace$/,""],[/^v:shapetype/,""],[new RegExp(l.join("|")),""]],elements:{a:function(t){if(t.attributes.name){if("_GoBack"==t.attributes.name)return void delete t.name;if(t.attributes.name.match(/^OLE_LINK\d+$/))return void delete t.name}if(t.attributes.href&&t.attributes.href.match(/#.+$/)){var e=t.attributes.href.match(/#(.+)$/)[1];o[e]=t}t.attributes.name&&o[t.attributes.name]&&((t=o[t.attributes.name]).attributes.href=t.attributes.href.replace(/.*#(.*)$/,"#$1"))},div:function(t){i.createStyleStack(t,n,m)},img:function(t){if(t.parent&&t.parent.attributes){var e=t.parent.attributes;(e=e.style||e.STYLE)&&e.match(/mso\-list:\s?Ignore/)&&(t.attributes["cke-ignored"]=!0)}i.mapStyles(t,{width:function(e){i.setStyle(t,"width",e+"px")},height:function(e){i.setStyle(t,"height",e+"px")}}),t.attributes.src&&t.attributes.src.match(/^file:\/\//)&&t.attributes.alt&&t.attributes.alt.match(/^https?:\/\//)&&(t.attributes.src=t.attributes.alt)},p:function(t){if(t.filterChildren(n),t.attributes.style&&t.attributes.style.match(/display:\s*none/i))return!1;if(r.thisIsAListItem(m,t))s.isEdgeListItem(m,t)&&s.cleanupEdgeListItem(t),r.convertToFakeListItem(m,t),a.array.reduce(t.children,function(t,e){return"p"===e.name&&(0<t&&new CKEDITOR.htmlParser.element("br").insertBefore(e),e.replaceWithChildren(),t+=1),t},0);else{var e=t.getAscendant(function(t){return"ul"==t.name||"ol"==t.name}),l=a.parseCssText(t.attributes.style);e&&!e.attributes["cke-list-level"]&&l["mso-list"]&&l["mso-list"].match(/level/)&&(e.attributes["cke-list-level"]=l["mso-list"].match(/level(\d+)/)[1])}i.createStyleStack(t,n,m)},pre:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h1:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h2:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h3:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h4:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h5:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},h6:function(t){r.thisIsAListItem(m,t)&&r.convertToFakeListItem(m,t),i.createStyleStack(t,n,m)},font:function(t){if(t.getHtml().match(/^\s*$/))return new CKEDITOR.htmlParser.text(" ").insertAfter(t),!1;m&&!0===m.config.pasteFromWordRemoveFontStyles&&t.attributes.size&&delete t.attributes.size,CKEDITOR.dtd.tr[t.parent.name]&&CKEDITOR.tools.arrayCompare(CKEDITOR.tools.objectKeys(t.attributes),["class","style"])?i.createStyleStack(t,n,m):e(t,n)},ul:function(t){if(f)return"li"==t.parent.name&&0===a.indexOf(t.parent.children,t)&&i.setStyle(t.parent,"list-style-type","none"),r.dissolveList(t),!1},li:function(t){s.correctLevelShift(t),f&&(t.attributes.style=i.normalizedStyles(t,m),i.pushStylesLower(t))},ol:function(t){if(f)return"li"==t.parent.name&&0===a.indexOf(t.parent.children,t)&&i.setStyle(t.parent,"list-style-type","none"),r.dissolveList(t),!1},span:function(t){if(t.filterChildren(n),t.attributes.style=i.normalizedStyles(t,m),!t.attributes.style||t.attributes.style.match(/^mso\-bookmark:OLE_LINK\d+$/)||t.getHtml().match(/^(\s|&nbsp;)+$/)){for(var e=t.children.length-1;0<=e;e--)t.children[e].insertAfter(t);return!1}t.attributes.style.match(/FONT-FAMILY:\s*Symbol/i)&&t.forEach(function(t){t.value=t.value.replace(/&nbsp;/g,"")},CKEDITOR.NODE_TEXT,!0),i.createStyleStack(t,n,m)},table:function(t){t._tdBorders={},t.filterChildren(n);var e,r,s=0;for(r in t._tdBorders)t._tdBorders[r]>s&&(s=t._tdBorders[r],e=r);if(i.setStyle(t,"border",e),s=(e=t.parent)&&e.parent,e.name&&"div"===e.name&&e.attributes.align&&1===a.objectKeys(e.attributes).length&&1===e.children.length){for(t.attributes.align=e.attributes.align,r=e.children.splice(0),t.remove(),t=r.length-1;0<=t;t--)s.add(r[t],e.getIndex());e.remove()}},td:function(t){var e=(o=t.getAscendant("table"))._tdBorders,r=["border","border-top","border-right","border-bottom","border-left"],s=(o=a.parseCssText(o.attributes.style)).background||o.BACKGROUND;s&&i.setStyle(t,"background",s,!0),(o=o["background-color"]||o["BACKGROUND-COLOR"])&&i.setStyle(t,"background-color",o,!0);var l,o=a.parseCssText(t.attributes.style);for(l in o)s=o[l],delete o[l],o[l.toLowerCase()]=s;for(l=0;l<r.length;l++)o[r[l]]&&(e[s=o[r[l]]]=e[s]?e[s]+1:1);i.createStyleStack(t,n,m,/margin|text\-align|padding|list\-style\-type|width|height|border|white\-space|vertical\-align|background/i)},"v:imagedata":t,"v:shape":function(t){var e=!1;if(t.parent.getFirst(function(r){"img"==r.name&&r.attributes&&r.attributes["v:shapes"]==t.attributes.id&&(e=!0)}),e)return!1;var r="";t.forEach(function(t){t.attributes&&t.attributes.src&&(r=t.attributes.src)},CKEDITOR.NODE_ELEMENT,!0),t.filterChildren(n),t.name="img",t.attributes.src=t.attributes.src||r,delete t.attributes.type},style:function(){return!1},object:function(t){return!(!t.attributes||!t.attributes.data)}},attributes:{style:function(t,e){return i.normalizedStyles(e,m)||!1},"class":function(t){return""!==(t=t.replace(/(el\d+)|(font\d+)|msonormal|msolistparagraph\w*/gi,""))&&t},cellspacing:t,cellpadding:t,border:t,"v:shapes":t,"o:spid":t},comment:function(t){return t.match(/\[if.* supportFields.*\]/)&&c++,"[endif]"==t&&(c=0<c?c-1:0),!1},text:function(t,e){if(c)return"";var r=e.parent&&e.parent.parent;return r&&r.attributes&&r.attributes.style&&r.attributes.style.match(/mso-list:\s*ignore/i)?t.replace(/&nbsp;/g," "):t}});var p=new CKEDITOR.htmlParser.basicWriter;return n.applyTo(d),d.writeHtml(p),p.getHtml()},CKEDITOR.plugins.pastefromword.styles={setStyle:function(t,e,r,i){var s=a.parseCssText(t.attributes.style);i&&s[e]||(""===r?delete s[e]:s[e]=r,t.attributes.style=CKEDITOR.tools.writeCssText(s))},mapStyles:function(t,e){for(var r in e)t.attributes[r]&&("function"==typeof e[r]?e[r](t.attributes[r]):i.setStyle(t,e[r],t.attributes[r]),delete t.attributes[r])},normalizedStyles:function(t,e){var i="background-color:transparent border-image:none color:windowtext direction:ltr mso- text-indent visibility:visible div:border:none".split(" "),s="font-family font font-size color background-color line-height text-decoration".split(" "),n=function(){for(var t=[],e=0;e<arguments.length;e++)arguments[e]&&t.push(arguments[e]);return-1!==a.indexOf(i,t.join(":"))},l=e&&!0===e.config.pasteFromWordRemoveFontStyles,o=a.parseCssText(t.attributes.style);"cke:li"==t.name&&o["TEXT-INDENT"]&&o.MARGIN&&(t.attributes["cke-indentation"]=r.getElementIndentation(t),o.MARGIN=o.MARGIN.replace(/(([\w\.]+ ){3,3})[\d\.]+(\w+$)/,"$10$3"));for(var c=a.objectKeys(o),u=0;u<c.length;u++){var m=c[u].toLowerCase(),f=o[c[u]],d=CKEDITOR.tools.indexOf;(l&&-1!==d(s,m.toLowerCase())||n(null,m,f)||n(null,m.replace(/\-.*$/,"-"))||n(null,m)||n(t.name,m,f)||n(t.name,m.replace(/\-.*$/,"-"))||n(t.name,m)||n(f))&&delete o[c[u]]}return CKEDITOR.tools.writeCssText(o)},createStyleStack:function(t,e,r,s){var n=[];for(t.filterChildren(e),e=t.children.length-1;0<=e;e--)n.unshift(t.children[e]),t.children[e].remove();i.sortStyles(t),e=a.parseCssText(i.normalizedStyles(t,r)),r=t;var l,o="span"===t.name;for(l in e)if(!l.match(s||/margin|text\-align|width|border|padding/i))if(o)o=!1;else{var c=new CKEDITOR.htmlParser.element("span");c.attributes.style=l+":"+e[l],r.add(c),r=c,delete e[l]}for(CKEDITOR.tools.isEmpty(e)?delete t.attributes.style:t.attributes.style=CKEDITOR.tools.writeCssText(e),e=0;e<n.length;e++)r.add(n[e])},sortStyles:function(t){for(var e=["border","border-bottom","font-size","background"],r=a.parseCssText(t.attributes.style),i=a.objectKeys(r),s=[],n=[],l=0;l<i.length;l++)-1!==a.indexOf(e,i[l].toLowerCase())?s.push(i[l]):n.push(i[l]);for(s.sort(function(t,r){return a.indexOf(e,t.toLowerCase())-a.indexOf(e,r.toLowerCase())}),i=[].concat(s,n),s={},l=0;l<i.length;l++)s[i[l]]=r[i[l]];t.attributes.style=CKEDITOR.tools.writeCssText(s)},pushStylesLower:function(t,e,r){if(!t.attributes.style||0===t.children.length)return!1;e=e||{};var s,n={"list-style-type":!0,width:!0,height:!0,border:!0,"border-":!0},l=a.parseCssText(t.attributes.style);for(s in l)if(!(s.toLowerCase()in n||n[s.toLowerCase().replace(/\-.*$/,"-")]||s.toLowerCase()in e)){for(var o=!1,c=0;c<t.children.length;c++){var u=t.children[c];if(u.type===CKEDITOR.NODE_TEXT&&r){var m=new CKEDITOR.htmlParser.element("span");m.setHtml(u.value),u.replaceWith(m),u=m}u.type===CKEDITOR.NODE_ELEMENT&&(o=!0,i.setStyle(u,s,l[s]))}o&&delete l[s]}return t.attributes.style=CKEDITOR.tools.writeCssText(l),!0},inliner:{filtered:"break-before break-after break-inside page-break page-break-before page-break-after page-break-inside".split(" "),parse:function(t){function e(t){var e=new CKEDITOR.dom.element("style"),r=new CKEDITOR.dom.element("iframe");return r.hide(),CKEDITOR.document.getBody().append(r),r.$.contentDocument.documentElement.appendChild(e.$),e.$.textContent=t,r.remove(),e.$.sheet}function r(t){var e=t.indexOf("{"),r=t.indexOf("}");return s(t.substring(e+1,r),!0)}var i,s=CKEDITOR.tools.parseCssText,n=CKEDITOR.plugins.pastefromword.styles.inliner.filter,a=t.is?t.$.sheet:e(t);if(t=[],a)for(a=a.cssRules,i=0;i<a.length;i++)a[i].type===window.CSSRule.STYLE_RULE&&t.push({selector:a[i].selectorText,styles:n(r(a[i].cssText))});return t},filter:function(t){var e,r=CKEDITOR.plugins.pastefromword.styles.inliner.filtered,i=a.array.indexOf,s={};for(e in t)-1===i(r,e)&&(s[e]=t[e]);return s},sort:function(t){return t.sort(function(t){var e=CKEDITOR.tools.array.map(t,function(t){return t.selector});return function(t,r){var i=-1!==(""+t.selector).indexOf(".")?1:0;return 0!==(i=(-1!==(""+r.selector).indexOf(".")?1:0)-i)?i:e.indexOf(r.selector)-e.indexOf(t.selector)}}(t))},inline:function(t){var e=CKEDITOR.plugins.pastefromword.styles.inliner.parse,r=CKEDITOR.plugins.pastefromword.styles.inliner.sort,i=function(t){return t=(new DOMParser).parseFromString(t,"text/html"),new CKEDITOR.dom.document(t)}(t);return r=r(function(t){var r,i=[];for(r=0;r<t.count();r++)i=i.concat(e(t.getItem(r)));return i}(t=i.find_by(id: "style"))),CKEDITOR.tools.array.forEach(r,function(t){var e,r,s,n=t.styles;for(t=i.find_by(id: t.selector),s=0;s<t.count();s++)e=t.getItem(s),r=CKEDITOR.tools.parseCssText(e.getAttribute("style")),r=CKEDITOR.tools.extend({},r,n),e.setAttribute("style",CKEDITOR.tools.writeCssText(r))}),i}}},i=CKEDITOR.plugins.pastefromword.styles,CKEDITOR.plugins.pastefromword.lists={thisIsAListItem:function(t,e){return!!(s.isEdgeListItem(t,e)||e.attributes.style&&e.attributes.style.match(/mso\-list:\s?l\d/)&&"li"!==e.parent.name||e.attributes["cke-dissolved"]||e.getHtml().match(/<!\-\-\[if !supportLists]\-\->/))},convertToFakeListItem:function(t,e){if(s.isDegenerateListItem(t,e)&&s.assignListLevels(t,e),this.getListItemInfo(e),!e.attributes["cke-dissolved"]){var i;if(e.forEach(function(t){!i&&"img"==t.name&&t.attributes["cke-ignored"]&&"*"==t.attributes.alt&&(i="\xb7",t.remove())},CKEDITOR.NODE_ELEMENT),e.forEach(function(t){i||t.value.match(/^ /)||(i=t.value)},CKEDITOR.NODE_TEXT),void 0===i)return;e.attributes["cke-symbol"]=i.replace(/(?: |&nbsp;).*$/,""),r.removeSymbolText(e)}if(e.attributes.style){var n=a.parseCssText(e.attributes.style);n["margin-left"]&&(delete n["margin-left"],e.attributes.style=CKEDITOR.tools.writeCssText(n))}e.name="cke:li"},convertToRealListItems:function(t){var e=[];return t.forEach(function(t){"cke:li"==t.name&&(t.name="li",e.push(t))},CKEDITOR.NODE_ELEMENT,!1),e},removeSymbolText:function(t){var e,r=t.attributes["cke-symbol"];t.forEach(function(i){!e&&i.value.match(r.replace(")","\\)").replace("(",""))&&(i.value=i.value.replace(r,""),i.parent.getHtml().match(/^(\s|&nbsp;)*$/)&&(e=i.parent!==t?i.parent:null))},CKEDITOR.NODE_TEXT),e&&e.remove()},setListSymbol:function(t,e,i){i=i||1;var s=a.parseCssText(t.attributes.style);if("ol"==t.name){if(t.attributes.type||s["list-style-type"])return;var n,l={"[ivx]":"lower-roman","[IVX]":"upper-roman","[a-z]":"lower-alpha","[A-Z]":"upper-alpha","\\d":"decimal"};for(n in l)if(r.getSubsectionSymbol(e).match(new RegExp(n))){s["list-style-type"]=l[n];break}t.attributes["cke-list-style-type"]=s["list-style-type"]}else l={"\xb7":"disc",o:"circle","\xa7":"square"},!s["list-style-type"]&&l[e]&&(s["list-style-type"]=l[e]);r.setListSymbol.removeRedundancies(s,i),(t.attributes.style=CKEDITOR.tools.writeCssText(s))||delete t.attributes.style},setListStart:function(t){for(var e=[],i=0,s=0;s<t.children.length;s++)e.push(t.children[s].attributes["cke-symbol"]||"");switch(e[0]||i++,t.attributes["cke-list-style-type"]){case"lower-roman":case"upper-roman":t.attributes.start=r.toArabic(r.getSubsectionSymbol(e[i]))-i;break;case"lower-alpha":case"upper-alpha":t.attributes.start=r.getSubsectionSymbol(e[i]).replace(/\W/g,"").toLowerCase().charCodeAt(0)-96-i;break;case"decimal":t.attributes.start=parseInt(r.getSubsectionSymbol(e[i]),10)-i||1}"1"==t.attributes.start&&delete t.attributes.start,delete t.attributes["cke-list-style-type"]},numbering:{toNumber:function(t,e){function r(t){t=t.toUpperCase();for(var e=1,r=1;0<t.length;r*=26)e+="ABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(t.charAt(t.length-1))*r,t=t.substr(0,t.length-1);return e}function i(t){var e=[[1e3,"M"],[900,"CM"],[500,"D"],[400,"CD"],[100,"C"],[90,"XC"],[50,"L"],[40,"XL"],[10,"X"],[9,"IX"],[5,"V"],[4,"IV"],[1,"I"]];t=t.toUpperCase();for(var r=e.length,i=0,s=0;s<r;++s)for(var n=e[s],a=n[1].length;t.substr(0,a)==n[1];t=t.substr(a))i+=n[0];return i}return"decimal"==e?Number(t):"upper-roman"==e||"lower-roman"==e?i(t.toUpperCase()):"lower-alpha"==e||"upper-alpha"==e?r(t):1},getStyle:function(t){var e={i:"lower-roman",v:"lower-roman",x:"lower-roman",l:"lower-roman",m:"lower-roman",I:"upper-roman",V:"upper-roman",X:"upper-roman",L:"upper-roman",M:"upper-roman"}[t=t.slice(0,1)];return e||(e="decimal",t.match(/[a-z]/)&&(e="lower-alpha"),t.match(/[A-Z]/)&&(e="upper-alpha")),e}},getSubsectionSymbol:function(t){return(t.match(/([\da-zA-Z]+).?$/)||["placeholder","1"])[1]},setListDir:function(t){var e=0,r=0;t.forEach(function(t){"li"==t.name&&("rtl"==(t.attributes.dir||t.attributes.DIR||"").toLowerCase()?r++:e++)},CKEDITOR.ELEMENT_NODE),r>e&&(t.attributes.dir="rtl")},createList:function(t){return(t.attributes["cke-symbol"].match(/([\da-np-zA-NP-Z]).?/)||[])[1]?new CKEDITOR.htmlParser.element("ol"):new CKEDITOR.htmlParser.element("ul")},createLists:function(t){var e,i,s,n=r.convertToRealListItems(t);if(0===n.length)return[];var a=r.groupLists(n);for(t=0;t<a.length;t++){var l=a[t],o=l[0];for(s=0;s<l.length;s++)if(1==l[s].attributes["cke-list-level"]){o=l[s];break}var c=(o=[r.createList(o)])[0],u=[o[0]];for(c.insertBefore(l[0]),s=0;s<l.length;s++){for(i=(e=l[s]).attributes["cke-list-level"];i>o.length;){var m=r.createList(e),f=c.children;0<f.length?f[f.length-1].add(m):((f=new CKEDITOR.htmlParser.element("li",{style:"list-style-type:none"})).add(m),c.add(f)),o.push(m),u.push(m),c=m,i==o.length&&r.setListSymbol(m,e.attributes["cke-symbol"],i)}for(;i<o.length;)o.pop(),c=o[o.length-1],i==o.length&&r.setListSymbol(c,e.attributes["cke-symbol"],i);e.remove(),c.add(e)}for(o[0].children.length&&(!(s=o[0].children[0].attributes["cke-symbol"])&&1<o[0].children.length&&(s=o[0].children[1].attributes["cke-symbol"]),s&&r.setListSymbol(o[0],s)),s=0;s<u.length;s++)r.setListStart(u[s]);for(s=0;s<l.length;s++)this.determineListItemValue(l[s])}return n},cleanup:function(t){var e,r,i=["cke-list-level","cke-symbol","cke-list-id","cke-indentation","cke-dissolved"];for(e=0;e<t.length;e++)for(r=0;r<i.length;r++)delete t[e].attributes[i[r]]},determineListItemValue:function(t){if("ol"===t.parent.name){var e,r=this.calculateValue(t),i=t.attributes["cke-symbol"].match(/[a-z0-9]+/gi);i&&(i=i[i.length-1],e=t.parent.attributes["cke-list-style-type"]||this.numbering.getStyle(i),(i=this.numbering.toNumber(i,e))!==r&&(t.attributes.value=i))}},calculateValue:function(t){if(!t.parent)return 1;var e,r,i,s=t.parent,n=null;for(i=t=t.getIndex();0<=i&&null===n;i--)(r=s.children[i]).attributes&&void 0!==r.attributes.value&&(e=i,n=parseInt(r.attributes.value,10));return null===n&&(n=void 0!==s.attributes.start?parseInt(s.attributes.start,10):1,e=0),n+(t-e)},dissolveList:function(t){function e(t){return 50<=t?"l"+e(t-50):40<=t?"xl"+e(t-40):10<=t?"x"+e(t-10):9==t?"ix":5<=t?"v"+e(t-5):4==t?"iv":1<=t?"i"+e(t-1):""}function r(t,e){function r(e,i){return e&&e.parent?t(e.parent)?r(e.parent,i+1):r(e.parent,i):i}return r(e,0)}var s,n,l=function(t){return function(e){return e.name==t}},o=function(t){return l("ul")(t)||l("ol")(t)},c=CKEDITOR.tools.array,u=[];t.forEach(function(t){u.push(t)},CKEDITOR.NODE_ELEMENT,!1),s=c.filter(u,l("li"));var m=c.filter(u,o);for(c.forEach(m,function(t){var i=t.attributes.type,s=parseInt(t.attributes.start,10)||1,n=r(o,t)+1;i||(i=a.parseCssText(t.attributes.style)["list-style-type"]),c.forEach(c.filter(t.children,l("li")),function(r,a){var l;switch(i){case"disc":l="\xb7";break;case"circle":l="o";break;case"square":l="\xa7";break;case"1":case"decimal":l=s+a+".";break;case"a":case"lower-alpha":l=String.fromCharCode(97+s-1+a)+".";break;case"A":case"upper-alpha":l=String.fromCharCode(65+s-1+a)+".";break;case"i":case"lower-roman":l=e(s+a)+".";break;case"I":case"upper-roman":l=e(s+a).toUpperCase()+".";break;default:l="ul"==t.name?"\xb7":s+a+"."}r.attributes["cke-symbol"]=l,r.attributes["cke-list-level"]=n})}),n=(s=c.reduce(s,function(t,e){var r=e.children[0];if(r&&r.name&&r.attributes.style&&r.attributes.style.match(/mso-list:/i)){i.pushStylesLower(e,{"list-style-type":!0,display:!0});var s=a.parseCssText(r.attributes.style,!0);i.setStyle(e,"mso-list",s["mso-list"],!0),i.setStyle(r,"mso-list",""),delete e["cke-list-level"],(r=s.display?"display":s.DISPLAY?"DISPLAY":"")&&i.setStyle(e,"display",s[r],!0)}return 1===e.children.length&&o(e.children[0])?t:(e.name="p",e.attributes["cke-dissolved"]=!0,t.push(e),t)},[])).length-1;0<=n;n--)s[n].insertAfter(t);for(n=m.length-1;0<=n;n--)delete m[n].name},groupLists:function(t){var e,i,s=[[t[0]]],n=s[0];for((i=t[0]).attributes["cke-indentation"]=i.attributes["cke-indentation"]||r.getElementIndentation(i),e=1;e<t.length;e++){i=t[e];var a=t[e-1];i.attributes["cke-indentation"]=i.attributes["cke-indentation"]||r.getElementIndentation(i),i.previous!==a&&(r.chopDiscontinuousLists(n,s),s.push(n=[])),n.push(i)}return r.chopDiscontinuousLists(n,s),s},chopDiscontinuousLists:function(t,e){for(var i,s={},n=[[]],l=0;l<t.length;l++){var o,c,u=s[t[l].attributes["cke-list-level"]],m=this.getListItemInfo(t[l]);for(u?(c=u.type.match(/alpha/)&&7==u.index?"alpha":c,c="o"==t[l].attributes["cke-symbol"]&&14==u.index?"alpha":c,o=r.getSymbolInfo(t[l].attributes["cke-symbol"],c),m=this.getListItemInfo(t[l]),(u.type!=o.type||i&&m.id!=i.id&&!this.isAListContinuation(t[l]))&&n.push([])):o=r.getSymbolInfo(t[l].attributes["cke-symbol"]),i=parseInt(t[l].attributes["cke-list-level"],10)+1;20>i;i++)s[i]&&delete s[i];s[t[l].attributes["cke-list-level"]]=o,n[n.length-1].push(t[l]),i=m}[].splice.apply(e,[].concat([a.indexOf(e,t),1],n))},isAListContinuation:function(t){var e=t;do{if((e=e.previous)&&e.type===CKEDITOR.NODE_ELEMENT){if(void 0===e.attributes["cke-list-level"])break;if(e.attributes["cke-list-level"]===t.attributes["cke-list-level"])return e.attributes["cke-list-id"]===t.attributes["cke-list-id"]}}while(e);return!1},getElementIndentation:function(t){if((t=a.parseCssText(t.attributes.style)).margin||t.MARGIN){t.margin=t.margin||t.MARGIN;var e={styles:{margin:t.margin}};CKEDITOR.filter.transformationsTools.splitMarginShorthand(e),t["margin-left"]=e.styles["margin-left"]}return parseInt(a.convertToPx(t["margin-left"]||"0px"),10)},toArabic:function(t){return t.match(/[ivxl]/i)?t.match(/^l/i)?50+r.toArabic(t.slice(1)):t.match(/^lx/i)?40+r.toArabic(t.slice(1)):t.match(/^x/i)?10+r.toArabic(t.slice(1)):t.match(/^ix/i)?9+r.toArabic(t.slice(2)):t.match(/^v/i)?5+r.toArabic(t.slice(1)):t.match(/^iv/i)?4+r.toArabic(t.slice(2)):t.match(/^i/i)?1+r.toArabic(t.slice(1)):r.toArabic(t.slice(1)):0},getSymbolInfo:function(t,e){var i=t.toUpperCase()==t?"upper-":"lower-",s={"\xb7":["disc",-1],o:["circle",-2],"\xa7":["square",-3]};return t in s||e&&e.match(/(disc|circle|square)/)?{index:s[t][1],type:s[t][0]}:t.match(/\d/)?{index:t?parseInt(r.getSubsectionSymbol(t),10):0,type:"decimal"}:(t=t.replace(/\W/g,"").toLowerCase(),!e&&t.match(/[ivxl]+/i)||e&&"alpha"!=e||"roman"==e?{index:r.toArabic(t),type:i+"roman"}:t.match(/[a-z]/i)?{index:t.charCodeAt(0)-97,type:i+"alpha"}:{index:-1,type:"disc"})},getListItemInfo:function(t){if(void 0!==t.attributes["cke-list-id"])return{id:t.attributes["cke-list-id"],level:t.attributes["cke-list-level"]};var e=a.parseCssText(t.attributes.style)["mso-list"],r={id:"0",level:"1"};return e&&(e+=" ",r.level=e.match(/level(.+?)\s+/)[1],r.id=e.match(/l(\d+?)\s+/)[1]),t.attributes["cke-list-level"]=void 0!==t.attributes["cke-list-level"]?t.attributes["cke-list-level"]:r.level,t.attributes["cke-list-id"]=r.id,r}},r=CKEDITOR.plugins.pastefromword.lists,CKEDITOR.plugins.pastefromword.heuristics={isEdgeListItem:function(t,e){if(!CKEDITOR.env.edge||!t.config.pasteFromWord_heuristicsEdgeList)return!1;var r="";return e.forEach&&e.forEach(function(t){r+=t.value},CKEDITOR.NODE_TEXT),!!r.match(/^(?: |&nbsp;)*\(?[a-zA-Z0-9]+?[\.\)](?: |&nbsp;){2,}/)||s.isDegenerateListItem(t,e)},cleanupEdgeListItem:function(t){var e=!1;t.forEach(function(t){e||(t.value=t.value.replace(/^(?:&nbsp;|[\s])+/,""),t.value.length&&(e=!0))},CKEDITOR.NODE_TEXT)},isDegenerateListItem:function(t,e){return!!e.attributes["cke-list-level"]||e.attributes.style&&!e.attributes.style.match(/mso\-list/)&&!!e.find_by(id: function(t){if(t.type==CKEDITOR.NODE_ELEMENT&&e.name.match(/h\d/i)&&t.getHtml().match(/^[a-zA-Z0-9]+?[\.\)]$/))return!0;var r=a.parseCssText(t.attributes&&t.attributes.style,!0);if(!r)return!1;var i=r["font-family"]||"";return(r.font||r["font-size"]||"").match(/7pt/i)&&!!t.previous||i.match(/symbol/i)},!0).length},assignListLevels:function(t,e){if(!e.attributes||void 0===e.attributes["cke-list-level"]){for(var i=[r.getElementIndentation(e)],n=[e],a=[],l=CKEDITOR.tools.array,o=l.map;e.next&&e.next.attributes&&!e.next.attributes["cke-list-level"]&&s.isDegenerateListItem(t,e.next);)e=e.next,i.push(r.getElementIndentation(e)),n.push(e);var c=o(i,function(t,e){return 0===e?0:t-i[e-1]}),u=this.guessIndentationStep(l.filter(i,function(t){return 0!==t}));a=o(i,function(t){return Math.round(t/u)});return-1!==l.indexOf(a,0)&&(a=o(a,function(t){return t+1})),l.forEach(n,function(t,e){t.attributes["cke-list-level"]=a[e]}),{indents:i,levels:a,diffs:c}}},guessIndentationStep:function(t){return t.length?Math.min.apply(null,t):null},correctLevelShift:function(t){if(this.isShifted(t)){var e=CKEDITOR.tools.array.filter(t.children,function(t){return"ul"==t.name||"ol"==t.name}),r=CKEDITOR.tools.array.reduce(e,function(t,e){return(e.children&&1==e.children.length&&s.isShifted(e.children[0])?[e]:e.children).concat(t)},[]);CKEDITOR.tools.array.forEach(e,function(t){t.remove()}),CKEDITOR.tools.array.forEach(r,function(e){t.add(e,0)}),delete t.name}},isShifted:function(t){return"li"===t.name&&0===CKEDITOR.tools.array.filter(t.children,function(t){return!t.name||"ul"!=t.name&&"ol"!=t.name&&("p"!=t.name||0!==t.children.length)}).length}},s=CKEDITOR.plugins.pastefromword.heuristics,r.setListSymbol.removeRedundancies=function(t,e){(1===e&&"disc"===t["list-style-type"]||"decimal"===t["list-style-type"])&&delete t["list-style-type"]},CKEDITOR.plugins.pastefromword.createAttributeStack=e,CKEDITOR.config.pasteFromWord_heuristicsEdgeList=!0}();