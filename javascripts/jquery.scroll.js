(function(){var e=jQuery.event.special,t="D"+ +(new Date),n="D"+(+(new Date)+1);e.scrollstart={setup:function(){var n,r=function(t){var r=this,i=arguments;n?clearTimeout(n):(t.type="scrollstart",jQuery.event.handle.apply(r,i)),n=setTimeout(function(){n=null},e.scrollstop.latency)};jQuery(this).bind("scroll",r).data(t,r)},teardown:function(){jQuery(this).unbind("scroll",jQuery(this).data(t))}},e.scrollstop={latency:300,setup:function(){var t,r=function(n){var r=this,i=arguments;t&&clearTimeout(t),t=setTimeout(function(){t=null,n.type="scrollstop",jQuery.event.handle.apply(r,i)},e.scrollstop.latency)};jQuery(this).bind("scroll",r).data(n,r)},teardown:function(){jQuery(this).unbind("scroll",jQuery(this).data(n))}}})();