(function(t){function e(e){for(var n,s,i=e[0],c=e[1],l=e[2],u=0,p=[];u<i.length;u++)s=i[u],Object.prototype.hasOwnProperty.call(r,s)&&r[s]&&p.push(r[s][0]),r[s]=0;for(n in c)Object.prototype.hasOwnProperty.call(c,n)&&(t[n]=c[n]);d&&d(e);while(p.length)p.shift()();return o.push.apply(o,l||[]),a()}function a(){for(var t,e=0;e<o.length;e++){for(var a=o[e],n=!0,s=1;s<a.length;s++){var c=a[s];0!==r[c]&&(n=!1)}n&&(o.splice(e--,1),t=i(i.s=a[0]))}return t}var n={},r={app:0},o=[];function s(t){return i.p+"js/"+({about:"about"}[t]||t)+"."+{about:"9de128a9"}[t]+".js"}function i(e){if(n[e])return n[e].exports;var a=n[e]={i:e,l:!1,exports:{}};return t[e].call(a.exports,a,a.exports,i),a.l=!0,a.exports}i.e=function(t){var e=[],a=r[t];if(0!==a)if(a)e.push(a[2]);else{var n=new Promise((function(e,n){a=r[t]=[e,n]}));e.push(a[2]=n);var o,c=document.createElement("script");c.charset="utf-8",c.timeout=120,i.nc&&c.setAttribute("nonce",i.nc),c.src=s(t);var l=new Error;o=function(e){c.onerror=c.onload=null,clearTimeout(u);var a=r[t];if(0!==a){if(a){var n=e&&("load"===e.type?"missing":e.type),o=e&&e.target&&e.target.src;l.message="Loading chunk "+t+" failed.\n("+n+": "+o+")",l.name="ChunkLoadError",l.type=n,l.request=o,a[1](l)}r[t]=void 0}};var u=setTimeout((function(){o({type:"timeout",target:c})}),12e4);c.onerror=c.onload=o,document.head.appendChild(c)}return Promise.all(e)},i.m=t,i.c=n,i.d=function(t,e,a){i.o(t,e)||Object.defineProperty(t,e,{enumerable:!0,get:a})},i.r=function(t){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(t,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(t,"__esModule",{value:!0})},i.t=function(t,e){if(1&e&&(t=i(t)),8&e)return t;if(4&e&&"object"===typeof t&&t&&t.__esModule)return t;var a=Object.create(null);if(i.r(a),Object.defineProperty(a,"default",{enumerable:!0,value:t}),2&e&&"string"!=typeof t)for(var n in t)i.d(a,n,function(e){return t[e]}.bind(null,n));return a},i.n=function(t){var e=t&&t.__esModule?function(){return t["default"]}:function(){return t};return i.d(e,"a",e),e},i.o=function(t,e){return Object.prototype.hasOwnProperty.call(t,e)},i.p="/",i.oe=function(t){throw console.error(t),t};var c=window["webpackJsonp"]=window["webpackJsonp"]||[],l=c.push.bind(c);c.push=e,c=c.slice();for(var u=0;u<c.length;u++)e(c[u]);var d=l;o.push([0,"chunk-vendors"]),a()})({0:function(t,e,a){t.exports=a("56d7")},"56d7":function(t,e,a){"use strict";a.r(e);a("e260"),a("e6cf"),a("cca6"),a("a79d");var n=a("2b0e"),r=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("v-app",[a("CountryStats")],1)},o=[],s=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",[a("v-app-bar",{attrs:{title:"true",flat:"",app:""}},[a("v-toolbar-title",{attrs:{bold:""}},[a("strong",{staticStyle:{color:"#44474f"}},[t._v("Covid19Besiege")]),a("span",{staticStyle:{"font-size":"15px"}},[t._v(" Statistics")])])],1),a("v-content",[a("transition",{attrs:{name:"fade"}},[a("v-alert",{staticClass:"messagesAlert mb-0",staticStyle:{"border-radius":"0px","text-align":"center"},attrs:{border:"top",color:"#247BA0",dark:""}},[t._v(t._s(t.currentMessage))])],1),a("v-container",[a("v-row",{staticStyle:{height:"100px"}},[a("v-col",{attrs:{md:"8",cols:"12"}},[a("v-row",[a("v-col",{attrs:{cols:"12",md:"6"}},[a("v-layout",{staticClass:"justify-center"},[a("div",{staticStyle:{"text-align":"center"}},[a("img",{staticStyle:{width:"20px"},attrs:{src:"https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/eg.svg",alt:""}}),a("h1",{staticStyle:{color:"#333333"}},[t._v(t._s(t.countryName))]),a("p",{staticStyle:{"font-size":"12px"}},[t._v(t._s(t.date))])])]),a("v-layout",{staticClass:"justify-center"},[a("div",[a("h5",[t._v(" Total Tests : "),a("span",{attrs:{id:"tests_number"}},[t._v(t._s(t.totalTests||"..."))])]),a("h5",[t._v(" Total Confirmed : "),a("span",{staticStyle:{"font-size":"20px"},attrs:{id:"cases_total"}},[t._v(t._s(t.totalConfirmed||"..."))])]),a("h5",[t._v(" Recovered : "),a("span",{staticStyle:{color:"rgb(41, 145, 41)"},attrs:{id:"recovered_total"}},[t._v(t._s(t.totalRecovered||"..."))])]),a("h5",[t._v(" Deaths : "),a("span",{staticStyle:{color:"rgb(153, 54, 54)"},attrs:{id:"deaths_total"}},[t._v(t._s(t.totalDeaths||"..."))])]),a("h5",[t._v(" Active : "),a("span",{staticStyle:{color:"blue"},attrs:{id:"active_total"}},[t._v(t._s(t.totalActive||"..."))])])])]),a("v-row",{staticClass:"mt-3 ma-0 pa-0"},[a("v-col",{staticClass:"ma-0 pa-0"},[a("h5",[t._v(" Today Cases : "),a("span",{staticStyle:{color:"rgb(94, 52, 52)"},attrs:{id:"today_cases"}},[t._v(t._s(t.todayCases||"..."))])])])],1),a("v-row",{staticClass:"ma-0 pa-0"},[a("v-col",{staticClass:"ma-0 pa-0"},[a("h5",[t._v(" Today Deaths : "),a("span",{attrs:{id:"today_deaths"}},[t._v(t._s(t.todayDeaths||"..."))])])])],1)],1),a("v-col",{staticClass:"pa-5",style:t.$vuetify.breakpoint.smAndDown?"background-color:#F5F5F5":"",attrs:{cols:"12",md:"6"}},[a("v-row",[a("v-col",[a("VueApexCharts",{attrs:{width:"100%",type:"donut",options:t.donutOptions,series:t.donutSeries}})],1)],1)],1)],1)],1),a("v-col",{attrs:{md:"4",cols:"12"}},[a("v-container",{attrs:{"fill-height":"",fluid:""}},[a("v-row",{attrs:{align:"center",justify:"center"}},[a("v-col",[t.loadingTrend?a("v-container",{attrs:{"fill-height":"",fluid:""}},[a("v-row",{attrs:{align:"center",justify:"center"}},[a("v-col",{attrs:{align:"center"}},[a("v-progress-circular",{attrs:{size:30,width:2,indeterminate:"",color:"primary"}})],1)],1)],1):a("VueApexCharts",{attrs:{width:"100%",type:"line",options:t.lineChartOptions,series:t.lineChartSeries}})],1)],1)],1)],1)],1)],1)],1)],1)},i=[],c=(a("99af"),a("d81d"),a("d3b7"),a("1321")),l=a.n(c),u={components:{VueApexCharts:l.a},data:function(){return{messages:["اغسل يديك بإستمرار جيدا بالماء و المطهرات لمدة لا تقل عن 20 ثانية","إن الله يحب المحسنين , كن محسناً مع الموظفين الذين يعملون معك كي نمر جميعا بهذه الأزمة إن شاء الله",'قال رسول الله ﷺ  "‏إذا سمعتم الطاعون بأرض، فلا تدخلوها، وإذا وقع بأرض، وأنتم فيها، فلا تخرجوا منها‏" - متفق عليه'],msgIndex:0,totalTests:null,totalConfirmed:null,totalRecovered:null,totalDeaths:null,totalActive:null,todayCases:null,todayDeaths:null,countryName:"Egypt",donutOptions:{labels:["Active Cases","Recovered","Deaths"],colors:["#247BA0","#51EB48","#dd6761"],plotOptions:{pie:{donut:{size:"50"}}}},donutSeries:[],loadingTrend:!0,lineChartSeries:[{name:"Active",data:[]},{name:"Recovered",data:[]},{name:"Deaths",data:[]}],lineChartOptions:{chart:{height:350,type:"line",stacked:!1},dataLabels:{enabled:!1},colors:["#247BA0","#51EB48","#FF1654"],stroke:{width:[4,4,4],curve:"smooth"},xaxis:{categories:[],labels:{hideOverlappingLabels:!0,showDuplicates:!1,tickAmount:"dataPoints"}},yaxis:[{opposite:!0}],tooltip:{shared:!1,intersect:!0,x:{show:!1}},legend:{horizontalAlign:"left",offsetX:40}}}},mounted:function(){var t=this;setInterval((function(){t.msgIndex>=t.messages.length-1?t.msgIndex=0:t.msgIndex+=1}),7e3),fetch("https://coronavirus-19-api.herokuapp.com/countries/egypt").then((function(t){return t.json()})).then((function(e){t.totalConfirmed=e.cases||"0",t.totalRecovered=e.recovered||"0",t.totalDeaths=e.deaths||"0",t.totalActive=e.active||"0",t.todayCases=e.todayCases||"0",t.totalTests=e.totalTests||"0",t.todayDeaths=e.todayDeaths||"0",t.donutSeries=[e.active,e.recovered,e.deaths]})),setTimeout((function(){var e=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];fetch("https://pomber.github.io/covid19/timeseries.json").then((function(t){return t.json()})).then((function(a){t.lineChartSeries[0].data=a["Egypt"].map((function(t){return t.confirmed})),t.lineChartSeries[1].data=a["Egypt"].map((function(t){return t.recovered})),t.lineChartSeries[2].data=a["Egypt"].map((function(t){return t.deaths}));var n=0;t.lineChartOptions.xaxis.categories=a["Egypt"].map((function(t){var a=new Date(t.date);return n+=1,n%14==0?"".concat(a.getDate(),"-").concat(e[a.getMonth()]):""})),t.loadingTrend=!1}))}),2e3)},methods:{formatAMPM:function(t){var e=new Intl.DateTimeFormat("en",{year:"numeric"}).format(t),a=new Intl.DateTimeFormat("en",{month:"short"}).format(t),n=new Intl.DateTimeFormat("en",{day:"2-digit"}).format(t),r=t.getHours(),o=t.getMinutes(),s=r>=12?"pm":"am";r%=12,r=r||12,o=o<10?"0"+o:o;var i="".concat(n,"-").concat(a,"-").concat(e,"  ")+r+":"+o+" "+s;return i}},computed:{currentMessage:function(){return this.messages[this.msgIndex]},date:function(){return this.formatAMPM(new Date)}}},d=u,p=(a("8933"),a("2877")),v=a("6544"),f=a.n(v),h=a("0798"),m=a("40dc"),y=a("62ad"),g=a("a523"),b=a("a75b"),_=a("a722"),w=a("490a"),C=a("0fd9"),S=a("2a7f"),x=Object(p["a"])(d,s,i,!1,null,null,null),A=x.exports;f()(x,{VAlert:h["a"],VAppBar:m["a"],VCol:y["a"],VContainer:g["a"],VContent:b["a"],VLayout:_["a"],VProgressCircular:w["a"],VRow:C["a"],VToolbarTitle:S["a"]});var T={components:{CountryStats:A}},j=T,O=a("7496"),D=Object(p["a"])(j,r,o,!1,null,null,null),M=D.exports;f()(D,{VApp:O["a"]});var P=a("8c4f");n["a"].use(P["a"]);var V=[{path:"/about",name:"About",component:function(){return a.e("about").then(a.bind(null,"f820"))}}],k=new P["a"]({routes:V}),E=k,F=a("2f62");n["a"].use(F["a"]);var I=new F["a"].Store({state:{},mutations:{},actions:{},modules:{}}),B=a("f309");n["a"].use(B["a"]);var R=new B["a"]({});n["a"].config.productionTip=!1,new n["a"]({router:E,store:I,vuetify:R,render:function(t){return t(M)}}).$mount("#app")},8933:function(t,e,a){"use strict";var n=a("fe92"),r=a.n(n);r.a},fe92:function(t,e,a){}});
//# sourceMappingURL=app.7d8a544c.js.map