(function(){var e,t,n,r,i,s,o,u,a,f,l,c,h,p,d,v,m,g,y,b,w,E;c=apiHost,s=$(window),t=$(document),e=$("body"),n=$(".js-load-more"),i=$(".share-facebook, .share-twitter"),a=function(){return!!window.history&&!!history.pushState},u=function(e){i.data("url",e);if(a())return history.pushState({},$("title").text(),e)},p=function(e){var t,n,r,i;return e==null||!e.is(":visible")?!1:(n=s.scrollTop(),t=n+s.height(),i=e.offset().top,r=i+e.height(),r<=t&&i>=n)},$.fn.serializeObject=function(){var e,t;return t={},e=this.serializeArray(),$.each(e,function(){return t[this.name]!==undefined?(t[this.name].push||(t[this.name]=[t[this.name]]),t[this.name].push(this.value||"")):t[this.name]=this.value||""}),t},l=function(e){var t,r,i,s,a,f,l,c,h,d;t=$(".places"),l=t.data("template-id"),a="",r=n.data("params"),i="",r!=null&&(i="?"+$.param(r)),u(window.location.origin+window.location.pathname+i),r!=null&&(!r.offset||parseInt(r.offset,10)===0)&&(e.data==null||e.data.length===0)&&(l=t.data("template-no-result-id"),l!=null&&t.append($("#"+l).html())),d=e.data;for(c=0,h=d.length;c<h;c++)f=d[c],a+=tmpl(l,f);t.append(a),$("body").addClass("s-collapse-titles");if(e.pageParams==null||e.pageParams.next==null)return n.data("url",null),n.data("params",null),n.hide();s=$.extend({},r,e.pageParams.next),n.data("params",s);if(p(n))return o()},h=!1,o=function(){var e;if(n!=null){e=n.data("url");if(e&&!h)return h=!0,n.show(),$.ajax({type:"GET",url:e,dataType:"json",data:n.data("params"),success:function(e){return h=!1,l(e)}})}},f=function(){if(p(n))return o()},f(),s.bind("scrollstop",f),r=$("form.pencarian"),r.on("submit",function(){var e,t;return $(".places").empty(),e=$(this),t=e.attr("action"),n!=null&&(n.show(),n.data("url",t),n.data("params",e.serializeObject())),$.ajax({type:"GET",url:t,dataType:"json",data:e.serialize(),success:l}),!1});if(r.length>0){v=window.location.search.substring(1).split("&"),g=!1;for(b=0,w=v.length;b<w;b++){m=v[b],E=m.split("="),d=E[0],y=E[1],d=decodeURIComponent(d),y=decodeURIComponent(y);if(y!=null&&y.length>0){if(d==="city"||d==="street"||d==="postalCode")g=!0;$("#place-"+d).val(y)}}g&&r.submit()}$(".share-facebook").on("click",function(){var e;return e="https://www.facebook.com/sharer/sharer.php?u=",window.open(e+($t.data("url")||window.location.href),"sharer","width=626,height=436")}),$(".share-twitter").on("click",function(){var e,t,n;return e=$(this),n="https://twitter.com/intent/tweet?",t={hashtags:e.data("hashtags"),original_referer:window.location.href,text:$("title").text(),tw_p:"tweetbutton",url:e.data("url")||window.location.href},window.open(n+$.param(t),"sharer","width=626,height=436")}),$(function(){return $("#place-city").autocomplete({serviceUrl:""+c+"/autocomplete/cities.json",minChars:3}),$("#place-postalCode").autocomplete({serviceUrl:""+c+"/autocomplete/postalCodes.json",minChars:3,onSelect:function(e,t){return $(this.form).submit()}})})}).call(this);