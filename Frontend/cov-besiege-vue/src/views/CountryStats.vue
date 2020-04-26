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
                    <country-flag :country="countryCode" size="big" />
                    <h1 style="color:#333333">{{ countryName }}</h1>
                    <v-autocomplete
                      :items="countries"
                      :filter="customFilter"
                      color="#333333"
                      item-text="name"
                      @change="selectionChanged"
                      label="Country"
                      solo
                    ></v-autocomplete>
                    <p style="font-size:12px;">{{ date }}</p>
                  </div>
                </v-layout>
                <v-skeleton-loader
                  v-if="loadingDonut && !donutError"
                  class="mx-auto"
                  max-width="300"
                  type="list-item-three-line"
                ></v-skeleton-loader>
                <v-layout v-if="!loadingDonut && !donutError" class="justify-center">
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
                  <v-col v-if="!loadingDonut && !donutError" class="ma-0 pa-0">
                    <h5>
                      Today Cases :
                      <span
                        style="color: rgb(94, 52, 52);"
                        id="today_cases"
                      >{{todayCases|| '...'}}</span>
                    </h5>
                  </v-col>
                </v-row>
                <v-row v-if="!loadingDonut && !donutError" class="ma-0 pa-0">
                  <v-col class="ma-0 pa-0">
                    <h5>
                      Today Deaths :
                      <span id="today_deaths">{{todayDeaths|| '...'}}</span>
                    </h5>
                  </v-col>
                </v-row>
                <v-row align="center" justify="center" v-if="donutError">
                  <v-col align="center">
                    <img
                      src="https://cdn0.iconfinder.com/data/icons/shift-free/32/Error-512.png"
                      style="width:25px;"
                      alt
                    />
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
                    <v-container v-if="loadingDonut && !donutError" fill-height fluid>
                      <v-row align="center" justify="center">
                        <v-col align="center">
                          <v-progress-circular :size="30" :width="2" indeterminate color="primary"></v-progress-circular>
                        </v-col>
                      </v-row>
                    </v-container>
                    <VueApexCharts
                      v-if="!loadingDonut && !donutError"
                      width="100%"
                      type="donut"
                      :options="donutOptions"
                      :series="donutSeries"
                    ></VueApexCharts>
                    <v-row align="center" justify="center" v-if="donutError">
                      <v-col align="center">
                        <img
                          src="https://cdn0.iconfinder.com/data/icons/shift-free/32/Error-512.png"
                          style="width:35px;"
                          alt
                        />
                      </v-col>
                    </v-row>
                  </v-col>
                </v-row>
              </v-col>
            </v-row>
          </v-col>
          <v-col md="4" cols="12" v-intersect="lineChartIntersect">
            <v-container fill-height fluid>
              <v-row align="center" justify="center">
                <v-col>
                  <v-container v-if="loadingTrend && !lineChartError" fill-height fluid>
                    <v-row align="center" justify="center">
                      <v-col align="center">
                        <v-progress-circular :size="30" :width="2" indeterminate color="primary"></v-progress-circular>
                      </v-col>
                    </v-row>
                  </v-container>
                  <VueApexCharts
                    v-if="!loadingTrend && !lineChartError"
                    width="100%"
                    type="line"
                    :options="lineChartOptions"
                    :series="lineChartSeries"
                  ></VueApexCharts>
                  <v-row align="center" justify="center" v-if="lineChartError">
                    <v-col align="center">
                      <img
                        src="https://cdn0.iconfinder.com/data/icons/shift-free/32/Error-512.png"
                        style="width:35px;"
                        alt
                      />
                    </v-col>
                  </v-row>
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
import CountryFlag from "vue-country-flag";

export default {
  components: {
    VueApexCharts,
    CountryFlag
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
      countryCode: "eg",
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
      loadingDonut: true,
      donutError: false,
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
      },
      countries: [
        { name: "Afghanistan", code: "AF" },
        { name: "Åland Islands", code: "AX" },
        { name: "Albania", code: "AL" },
        { name: "Algeria", code: "DZ" },
        { name: "American Samoa", code: "AS" },
        { name: "AndorrA", code: "AD" },
        { name: "Angola", code: "AO" },
        { name: "Anguilla", code: "AI" },
        { name: "Antarctica", code: "AQ" },
        { name: "Antigua and Barbuda", code: "AG" },
        { name: "Argentina", code: "AR" },
        { name: "Armenia", code: "AM" },
        { name: "Aruba", code: "AW" },
        { name: "Australia", code: "AU" },
        { name: "Austria", code: "AT" },
        { name: "Azerbaijan", code: "AZ" },
        { name: "Bahamas", code: "BS" },
        { name: "Bahrain", code: "BH" },
        { name: "Bangladesh", code: "BD" },
        { name: "Barbados", code: "BB" },
        { name: "Belarus", code: "BY" },
        { name: "Belgium", code: "BE" },
        { name: "Belize", code: "BZ" },
        { name: "Benin", code: "BJ" },
        { name: "Bermuda", code: "BM" },
        { name: "Bhutan", code: "BT" },
        { name: "Bolivia", code: "BO" },
        { name: "Bosnia and Herzegovina", code: "BA" },
        { name: "Botswana", code: "BW" },
        { name: "Bouvet Island", code: "BV" },
        { name: "Brazil", code: "BR" },
        { name: "British Indian Ocean Territory", code: "IO" },
        { name: "Brunei Darussalam", code: "BN" },
        { name: "Bulgaria", code: "BG" },
        { name: "Burkina Faso", code: "BF" },
        { name: "Burundi", code: "BI" },
        { name: "Cambodia", code: "KH" },
        { name: "Cameroon", code: "CM" },
        { name: "Canada", code: "CA" },
        { name: "Cape Verde", code: "CV" },
        { name: "Cayman Islands", code: "KY" },
        { name: "Central African Republic", code: "CF" },
        { name: "Chad", code: "TD" },
        { name: "Chile", code: "CL" },
        { name: "China", code: "CN" },
        { name: "Christmas Island", code: "CX" },
        { name: "Cocos (Keeling) Islands", code: "CC" },
        { name: "Colombia", code: "CO" },
        { name: "Comoros", code: "KM" },
        { name: "Congo", code: "CG" },
        { name: "Congo", code: "CD" },
        { name: "Cook Islands", code: "CK" },
        { name: "Costa Rica", code: "CR" },
        { name: "Cote D'Ivoire", code: "CI" },
        { name: "Croatia", code: "HR" },
        { name: "Cuba", code: "CU" },
        { name: "Cyprus", code: "CY" },
        { name: "Czech Republic", code: "CZ" },
        { name: "Denmark", code: "DK" },
        { name: "Djibouti", code: "DJ" },
        { name: "Dominica", code: "DM" },
        { name: "Dominican Republic", code: "DO" },
        { name: "Ecuador", code: "EC" },
        { name: "Egypt", code: "EG" },
        { name: "El Salvador", code: "SV" },
        { name: "Equatorial Guinea", code: "GQ" },
        { name: "Eritrea", code: "ER" },
        { name: "Estonia", code: "EE" },
        { name: "Ethiopia", code: "ET" },
        { name: "Falkland Islands (Malvinas)", code: "FK" },
        { name: "Faroe Islands", code: "FO" },
        { name: "Fiji", code: "FJ" },
        { name: "Finland", code: "FI" },
        { name: "France", code: "FR" },
        { name: "French Guiana", code: "GF" },
        { name: "French Polynesia", code: "PF" },
        { name: "French Southern Territories", code: "TF" },
        { name: "Gabon", code: "GA" },
        { name: "Gambia", code: "GM" },
        { name: "Georgia", code: "GE" },
        { name: "Germany", code: "DE" },
        { name: "Ghana", code: "GH" },
        { name: "Gibraltar", code: "GI" },
        { name: "Greece", code: "GR" },
        { name: "Greenland", code: "GL" },
        { name: "Grenada", code: "GD" },
        { name: "Guadeloupe", code: "GP" },
        { name: "Guam", code: "GU" },
        { name: "Guatemala", code: "GT" },
        { name: "Guernsey", code: "GG" },
        { name: "Guinea", code: "GN" },
        { name: "Guinea-Bissau", code: "GW" },
        { name: "Guyana", code: "GY" },
        { name: "Haiti", code: "HT" },
        { name: "Heard Island and Mcdonald Islands", code: "HM" },
        { name: "Holy See (Vatican City State)", code: "VA" },
        { name: "Honduras", code: "HN" },
        { name: "Hong Kong", code: "HK" },
        { name: "Hungary", code: "HU" },
        { name: "Iceland", code: "IS" },
        { name: "India", code: "IN" },
        { name: "Indonesia", code: "ID" },
        { name: "Iran, Islamic Republic Of Iran", code: "IR" },
        { name: "Iraq", code: "IQ" },
        { name: "Ireland", code: "IE" },
        { name: "Isle of Man", code: "IM" },
        { name: "Israel", code: "IL" },
        { name: "Italy", code: "IT" },
        { name: "Jamaica", code: "JM" },
        { name: "Japan", code: "JP" },
        { name: "Jersey", code: "JE" },
        { name: "Jordan", code: "JO" },
        { name: "Kazakhstan", code: "KZ" },
        { name: "Kenya", code: "KE" },
        { name: "Kiribati", code: "KI" },
        { name: "Korea North", code: "KP" },
        { name: "Korea South", code: "KR" },
        { name: "Kuwait", code: "KW" },
        { name: "Kyrgyzstan", code: "KG" },
        { name: "Lao People'S Democratic Republic", code: "LA" },
        { name: "Latvia", code: "LV" },
        { name: "Lebanon", code: "LB" },
        { name: "Lesotho", code: "LS" },
        { name: "Liberia", code: "LR" },
        { name: "Libyan Arab Jamahiriya", code: "LY" },
        { name: "Liechtenstein", code: "LI" },
        { name: "Lithuania", code: "LT" },
        { name: "Luxembourg", code: "LU" },
        { name: "Macao", code: "MO" },
        { name: "Macedonia", code: "MK" },
        { name: "Madagascar", code: "MG" },
        { name: "Malawi", code: "MW" },
        { name: "Malaysia", code: "MY" },
        { name: "Maldives", code: "MV" },
        { name: "Mali", code: "ML" },
        { name: "Malta", code: "MT" },
        { name: "Marshall Islands", code: "MH" },
        { name: "Martinique", code: "MQ" },
        { name: "Mauritania", code: "MR" },
        { name: "Mauritius", code: "MU" },
        { name: "Mayotte", code: "YT" },
        { name: "Mexico", code: "MX" },
        { name: "Micronesia", code: "FM" },
        { name: "Moldova", code: "MD" },
        { name: "Monaco", code: "MC" },
        { name: "Mongolia", code: "MN" },
        { name: "Montserrat", code: "MS" },
        { name: "Morocco", code: "MA" },
        { name: "Mozambique", code: "MZ" },
        { name: "Myanmar", code: "MM" },
        { name: "Namibia", code: "NA" },
        { name: "Nauru", code: "NR" },
        { name: "Nepal", code: "NP" },
        { name: "Netherlands", code: "NL" },
        { name: "Netherlands Antilles", code: "AN" },
        { name: "New Caledonia", code: "NC" },
        { name: "New Zealand", code: "NZ" },
        { name: "Nicaragua", code: "NI" },
        { name: "Niger", code: "NE" },
        { name: "Nigeria", code: "NG" },
        { name: "Niue", code: "NU" },
        { name: "Norfolk Island", code: "NF" },
        { name: "Northern Mariana Islands", code: "MP" },
        { name: "Norway", code: "NO" },
        { name: "Oman", code: "OM" },
        { name: "Pakistan", code: "PK" },
        { name: "Palau", code: "PW" },
        { name: "Palestinian Territory, Occupied", code: "PS" },
        { name: "Panama", code: "PA" },
        { name: "Papua New Guinea", code: "PG" },
        { name: "Paraguay", code: "PY" },
        { name: "Peru", code: "PE" },
        { name: "Philippines", code: "PH" },
        { name: "Pitcairn", code: "PN" },
        { name: "Poland", code: "PL" },
        { name: "Portugal", code: "PT" },
        { name: "Puerto Rico", code: "PR" },
        { name: "Qatar", code: "QA" },
        { name: "Reunion", code: "RE" },
        { name: "Romania", code: "RO" },
        { name: "Russian Federation", code: "RU" },
        { name: "RWANDA", code: "RW" },
        { name: "Saint Helena", code: "SH" },
        { name: "Saint Kitts and Nevis", code: "KN" },
        { name: "Saint Lucia", code: "LC" },
        { name: "Saint Pierre and Miquelon", code: "PM" },
        { name: "Saint Vincent and the Grenadines", code: "VC" },
        { name: "Samoa", code: "WS" },
        { name: "San Marino", code: "SM" },
        { name: "Sao Tome and Principe", code: "ST" },
        { name: "Saudi Arabia", code: "SA" },
        { name: "Senegal", code: "SN" },
        { name: "Serbia and Montenegro", code: "CS" },
        { name: "Seychelles", code: "SC" },
        { name: "Sierra Leone", code: "SL" },
        { name: "Singapore", code: "SG" },
        { name: "Slovakia", code: "SK" },
        { name: "Slovenia", code: "SI" },
        { name: "Solomon Islands", code: "SB" },
        { name: "Somalia", code: "SO" },
        { name: "South Africa", code: "ZA" },
        { name: "South Georgia and the South Sandwich Islands", code: "GS" },
        { name: "Spain", code: "ES" },
        { name: "Sri Lanka", code: "LK" },
        { name: "Sudan", code: "SD" },
        { name: "Suriname", code: "SR" },
        { name: "Svalbard and Jan Mayen", code: "SJ" },
        { name: "Swaziland", code: "SZ" },
        { name: "Sweden", code: "SE" },
        { name: "Switzerland", code: "CH" },
        { name: "Syrian Arab Republic", code: "SY" },
        { name: "Taiwan, Province of China", code: "TW" },
        { name: "Tajikistan", code: "TJ" },
        { name: "Tanzania", code: "TZ" },
        { name: "Thailand", code: "TH" },
        { name: "Timor-Leste", code: "TL" },
        { name: "Togo", code: "TG" },
        { name: "Tokelau", code: "TK" },
        { name: "Tonga", code: "TO" },
        { name: "Trinidad and Tobago", code: "TT" },
        { name: "Tunisia", code: "TN" },
        { name: "Turkey", code: "TR" },
        { name: "Turkmenistan", code: "TM" },
        { name: "Turks and Caicos Islands", code: "TC" },
        { name: "Tuvalu", code: "TV" },
        { name: "Uganda", code: "UG" },
        { name: "Ukraine", code: "UA" },
        { name: "United Arab Emirates", code: "AE" },
        { name: "United Kingdom", code: "GB" },
        { name: "United States", code: "US" },
        { name: "United States Minor Outlying Islands", code: "UM" },
        { name: "Uruguay", code: "UY" },
        { name: "Uzbekistan", code: "UZ" },
        { name: "Vanuatu", code: "VU" },
        { name: "Venezuela", code: "VE" },
        { name: "Viet Nam", code: "VN" },
        { name: "Virgin Islands, British", code: "VG" },
        { name: "Virgin Islands, U.S.", code: "VI" },
        { name: "Wallis and Futuna", code: "WF" },
        { name: "Western Sahara", code: "EH" },
        { name: "Yemen", code: "YE" },
        { name: "Zambia", code: "ZM" },
        { name: "Zimbabwe", code: "ZW" }
      ],
      countrySearchBuffer: [],
      searchBufferSize: 0,
      fetchedLineChartCountries: null,
      lineChartError: false
    };
  },
  mounted() {
    setInterval(() => {
      this.msgIndex >= this.messages.length - 1
        ? (this.msgIndex = 0)
        : (this.msgIndex += 1);
    }, 7000);
    this.fetchDonutChart(this.countryName);
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
    fetchDonutChart: function(countryName) {
      this.donutError = false;
      this.loadingDonut = true;
      fetch("https://coronavirus-19-api.herokuapp.com/countries/" + countryName)
        .then(response => response.json())
        .then(data => {
          this.loadingDonut = false;
          this.totalConfirmed = data.cases || 0;
          this.totalRecovered = data.recovered || 0;
          this.totalDeaths = data.deaths || 0;
          this.totalActive = data.active || 0;
          this.todayCases = data.todayCases || 0;
          this.totalTests = data.totalTests || 0;
          this.todayDeaths = data.todayDeaths || 0;

          this.donutSeries = [
            this.totalActive,
            this.totalRecovered,
            this.totalDeaths
          ];

          this.searchBufferSize = 0;
        })
        .catch(err => {
          if (this.countrySearchBuffer.length == 0) {
            this.donutError = true;
            this.loadingDonut = true;

            fetch("https://restcountries.eu/rest/v2/name/" + this.countryName)
              .then(response => response.json())
              .then(response => {
                this.countrySearchBuffer.push(
                  response.filter(
                    item =>
                      item.alpha2Code == this.countryCode ||
                      item.alpha3Code == this.countryCode
                  )[0].name
                );
                this.countrySearchBuffer.push(
                  response.filter(
                    item =>
                      item.alpha2Code == this.countryCode ||
                      item.alpha3Code == this.countryCode
                  )[0].alpha2Code
                );
                this.countrySearchBuffer.push(
                  response.filter(
                    item =>
                      item.alpha2Code == this.countryCode ||
                      item.alpha3Code == this.countryCode
                  )[0].alpha3Code
                );
                this.countrySearchBuffer.push.apply(
                  this.countrySearchBuffer,
                  response.filter(
                    item =>
                      item.alpha2Code == this.countryCode ||
                      item.alpha3Code == this.countryCode
                  )[0].altSpellings
                );
                this.countrySearchBuffer.push(
                  response.filter(
                    item =>
                      item.alpha2Code == this.countryCode ||
                      item.alpha3Code == this.countryCode
                  )[0].translations.it
                );

                if (this.searchBufferSize == this.countrySearchBuffer.length) {
                  this.searchBufferSize = 0;
                  this.donutError = true;
                  this.loadingDonut = false;
                  return;
                }

                this.searchBufferSize = this.countrySearchBuffer.length;

                this.fetchDonutChart(this.countrySearchBuffer[0]);
                this.countrySearchBuffer.length > 0
                  ? this.countrySearchBuffer.splice(0, 1)
                  : "";
              })
              .catch(err => {
                return;
              });
          } else {
            this.fetchDonutChart(this.countrySearchBuffer[0]);
            this.countrySearchBuffer.length > 0
              ? this.countrySearchBuffer.splice(0, 1)
              : "";
          }
        });
    },
    fetchLineChart: function() {
      this.loadingTrend = true;
      this.lineChartError = false;
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

      if (this.fetchedLineChartCountries == null)
        fetch("https://pomber.github.io/covid19/timeseries.json")
          .then(response => response.json())
          .then(data => {
            this.fetchedLineChartCountries = data;

            if (!data[this.countryName]) {
              this.lineChartError = true;
              return;
            }

            this.lineChartSeries[0].data = data[this.countryName].map(item => {
              return item.confirmed;
            });
            this.lineChartSeries[1].data = data[this.countryName].map(item => {
              return item.recovered;
            });
            this.lineChartSeries[2].data = data[this.countryName].map(item => {
              return item.deaths;
            });

            var counter = 0;
            this.lineChartOptions.xaxis.categories = data[this.countryName].map(
              item => {
                var date = new Date(item.date);
                counter += 1;

                return counter % 14 == 0
                  ? `${date.getDate()}-${monthNames[date.getMonth()]}`
                  : "";
              }
            );

            setTimeout(() => {
              this.loadingTrend = false;
            }, 2000);
          });
      else {
        if (!this.fetchedLineChartCountries[this.countryName]) {
          this.lineChartError = true;
          return;
        }
        console.log(this.fetchedLineChartCountries[this.countryName]);

        this.lineChartSeries[0].data = this.fetchedLineChartCountries[
          this.countryName
        ].map(item => {
          return item.confirmed;
        });
        this.lineChartSeries[1].data = this.fetchedLineChartCountries[
          this.countryName
        ].map(item => {
          return item.recovered;
        });
        this.lineChartSeries[2].data = this.fetchedLineChartCountries[
          this.countryName
        ].map(item => {
          return item.deaths;
        });

        var counter = 0;
        this.lineChartOptions.xaxis.categories = this.fetchedLineChartCountries[
          this.countryName
        ].map(item => {
          var date = new Date(item.date);
          counter += 1;

          return counter % 14 == 0
            ? `${date.getDate()}-${monthNames[date.getMonth()]}`
            : "";
        });

        setTimeout(() => {
          this.loadingTrend = false;
        }, 2000);
      }
    },
    customFilter(item, queryText, itemText) {
      const textOne = item.name.toLowerCase();
      const textTwo = item.code.toLowerCase();
      const searchText = queryText.toLowerCase();

      return (
        textOne.indexOf(searchText) > -1 || textTwo.indexOf(searchText) > -1
      );
    },
    selectionChanged(value) {
      this.countryName = value;
      this.countryCode = this.countries.filter(
        item => item.name == value
      )[0].code;
      this.fetchLineChart();
      this.fetchDonutChart(this.countryName);
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
