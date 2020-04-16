<template>
  <div>
    <v-app-bar title="true" flat app>
      <v-toolbar-title bold>
        <strong style="color:#44474f">Covid19Besiege</strong>
        <span style="font-size:15px;">&nbsp;Statistics</span>
      </v-toolbar-title>
    </v-app-bar>
    <v-content>
      <transition name="fade">
        <v-alert
          border="top"
          color="#247BA0"
          dark
          class="messagesAlert mb-0"
          style="border-radius:0px;text-align:center"
        >{{ currentMessage }}</v-alert>
      </transition>
      <v-container>
        <v-row style="height:100px;">
          <v-col md="8" cols="12">
            <v-row>
              <v-col cols="12" md="6">
                <v-layout class="justify-center">
                  <div style="text-align:center;">
                    <img
                      src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/eg.svg"
                      style="width:20px"
                      alt
                    />
                    <h1 style="color:#333333">{{ countryName }}</h1>
                    <p style="font-size:12px;">{{ date }}</p>
                  </div>
                </v-layout>
                <v-layout class="justify-center">
                  <div>
                    <h5>
                      Total Tests :
                      <span id="tests_number">{{totalTests || '...'}}</span>
                    </h5>
                    <h5>
                      Total Confirmed :
                      <span
                        id="cases_total"
                        style="font-size: 20px;"
                      >{{totalConfirmed || '...'}}</span>
                    </h5>
                    <h5>
                      Recovered :
                      <span
                        id="recovered_total"
                        style="color: rgb(41, 145, 41);"
                      >{{totalRecovered || '...'}}</span>
                    </h5>
                    <h5>
                      Deaths :
                      <span
                        id="deaths_total"
                        style="color: rgb(153, 54, 54);"
                      >{{totalDeaths|| '...'}}</span>
                    </h5>
                    <h5>
                      Active :
                      <span id="active_total" style="color: blue;">{{totalActive|| '...'}}</span>
                    </h5>
                  </div>
                </v-layout>
                <v-row class="mt-3 ma-0 pa-0">
                  <v-col class="ma-0 pa-0">
                    <h5>
                      Today Cases :
                      <span
                        style="color: rgb(94, 52, 52);"
                        id="today_cases"
                      >{{todayCases|| '...'}}</span>
                    </h5>
                  </v-col>
                </v-row>
                <v-row class="ma-0 pa-0">
                  <v-col class="ma-0 pa-0">
                    <h5>
                      Today Deaths :
                      <span id="today_deaths">{{todayDeaths|| '...'}}</span>
                    </h5>
                  </v-col>
                </v-row>
              </v-col>
              <v-col
                cols="12"
                md="6"
                class="pa-5"
                :style="$vuetify.breakpoint.smAndDown ? 'background-color:#F5F5F5':''"
              >
                <v-row>
                  <v-col>
                    <VueApexCharts
                      width="100%"
                      type="donut"
                      :options="donutOptions"
                      :series="donutSeries"
                    ></VueApexCharts>
                  </v-col>
                </v-row>
              </v-col>
            </v-row>
          </v-col>
          <v-col md="4" cols="12" v-intersect="lineChartIntersect">
            <v-container fill-height fluid>
              <v-row align="center" justify="center">
                <v-col>
                  <v-container v-if="loadingTrend" fill-height fluid>
                    <v-row align="center" justify="center">
                      <v-col align="center">
                        <v-progress-circular :size="30" :width="2" indeterminate color="primary"></v-progress-circular>
                      </v-col>
                    </v-row>
                  </v-container>
                  <VueApexCharts
                    v-else
                    width="100%"
                    type="line"
                    :options="lineChartOptions"
                    :series="lineChartSeries"
                  ></VueApexCharts>
                </v-col>
              </v-row>
            </v-container>
          </v-col>
        </v-row>
      </v-container>
    </v-content>
  </div>
</template>

<script>
import VueApexCharts from "vue-apexcharts";
export default {
  components: {
    VueApexCharts
  },
  data() {
    return {
      messages: [
        "اغسل يديك بإستمرار جيدا بالماء و المطهرات لمدة لا تقل عن 20 ثانية",
        "إن الله يحب المحسنين , كن محسناً مع الموظفين الذين يعملون معك كي نمر جميعا بهذه الأزمة إن شاء الله",
        'قال رسول الله ﷺ  "‏إذا سمعتم الطاعون بأرض، فلا تدخلوها، وإذا وقع بأرض، وأنتم فيها، فلا تخرجوا منها‏" - متفق عليه'
      ],
      msgIndex: 0,
      totalTests: null,
      totalConfirmed: null,
      totalRecovered: null,
      totalDeaths: null,
      totalActive: null,
      todayCases: null,
      todayDeaths: null,
      countryName: "Egypt",
      donutOptions: {
        labels: ["Active Cases", "Recovered", "Deaths"],
        colors: ["#247BA0", "#51EB48", "#dd6761"],
        plotOptions: {
          pie: {
            donut: {
              size: "50"
            }
          }
        }
      },
      donutSeries: [],
      loadingTrend: true,
      lineChartSeries: [
        {
          name: "Active",
          data: []
        },
        {
          name: "Recovered",
          data: []
        },
        {
          name: "Deaths",
          data: []
        }
      ],
      lineChartOptions: {
        chart: {
          height: 350,
          type: "line",
          stacked: false
        },
        dataLabels: {
          enabled: false
        },
        colors: ["#247BA0", "#51EB48", "#FF1654"],
        stroke: {
          width: [4, 4, 4],
          curve: "smooth"
        },
        xaxis: {
          categories: [],
          labels: {
            hideOverlappingLabels: true,
            showDuplicates: false,
            tickAmount: "dataPoints"
          }
        },
        yaxis: [
          {
            opposite: true
          }
        ],
        tooltip: {
          shared: false,
          intersect: true,
          x: {
            show: false
          }
        },
        legend: {
          horizontalAlign: "left",
          offsetX: 40
        }
      }
    };
  },
  mounted() {
    setInterval(() => {
      this.msgIndex >= this.messages.length - 1
        ? (this.msgIndex = 0)
        : (this.msgIndex += 1);
    }, 7000);

    fetch("https://coronavirus-19-api.herokuapp.com/countries/egypt")
      .then(response => response.json())
      .then(data => {
        this.totalConfirmed = data.cases || "0";
        this.totalRecovered = data.recovered || "0";
        this.totalDeaths = data.deaths || "0";
        this.totalActive = data.active || "0";
        this.todayCases = data.todayCases || "0";
        this.totalTests = data.totalTests || "0";
        this.todayDeaths = data.todayDeaths || "0";

        this.donutSeries = [data.active, data.recovered, data.deaths];
      });
  },
  methods: {
    formatAMPM: function(date) {
      const ye = new Intl.DateTimeFormat("en", { year: "numeric" }).format(
        date
      );
      const mo = new Intl.DateTimeFormat("en", { month: "short" }).format(date);
      const da = new Intl.DateTimeFormat("en", { day: "2-digit" }).format(date);

      var hours = date.getHours();
      var minutes = date.getMinutes();
      var ampm = hours >= 12 ? "pm" : "am";
      hours = hours % 12;
      hours = hours ? hours : 12; // the hour '0' should be '12'
      minutes = minutes < 10 ? "0" + minutes : minutes;
      var strTime = `${da}-${mo}-${ye}  ` + hours + ":" + minutes + " " + ampm;
      return strTime;
    },
    lineChartIntersect: function(entries) {
      if (entries[0].isIntersecting) this.fetchLineChart();
    },
    fetchLineChart: function() {
      const monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];

      fetch("https://pomber.github.io/covid19/timeseries.json")
        .then(response => response.json())
        .then(data => {
          this.lineChartSeries[0].data = data["Egypt"].map(item => {
            return item.confirmed;
          });
          this.lineChartSeries[1].data = data["Egypt"].map(item => {
            return item.recovered;
          });
          this.lineChartSeries[2].data = data["Egypt"].map(item => {
            return item.deaths;
          });

          var counter = 0;
          this.lineChartOptions.xaxis.categories = data["Egypt"].map(item => {
            var date = new Date(item.date);
            counter += 1;

            return counter % 14 == 0
              ? `${date.getDate()}-${monthNames[date.getMonth()]}`
              : "";
          });

          this.loadingTrend = false;
        });
    }
  },
  computed: {
    currentMessage: function() {
      return this.messages[this.msgIndex];
    },
    date: function() {
      return this.formatAMPM(new Date());
    }
  }
};
</script>

<style lang="scss">
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
</style>
