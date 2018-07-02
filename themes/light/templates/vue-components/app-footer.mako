<script type="text/x-template" id="app-footer-template">
<!-- BEGIN FOOTER -->
<footer v-if="loggedIn">
    <div class="footer clearfix">
        <span class="footerhighlight">{{ stats.shows.total }}</span> Shows (<span class="footerhighlight">{{ stats.shows.active }}</span> Active)
        | <span class="footerhighlight">{{ stats.episodes.downloaded }}</span><!-- Comment is needed to fix whitespace issues
        --><template v-if="stats.episodes.snatched">
            <span class="footerhighlight"><app-link :href="'manage/episodeStatuses?whichStatus=' + statuses.values.snatched" title="View overview of snatched episodes">+{{ stats.episodes.snatched }}</app-link></span>
            Snatched
        </template>
        / <span class="footerhighlight">{{ stats.episodes.total }}</span> Episodes Downloaded <span v-if="episodePercentage" class="footerhighlight">({{ episodePercentage }})</span>
        | Daily Search: <span class="footerhighlight">{{ timeLeft.daily }}</span>
        | Backlog Search: <span class="footerhighlight">{{ timeLeft.backlog }}</span>
        <div>
            <template v-if="memoryUsage">
            Memory used: <span class="footerhighlight">{{ memoryUsage }}</span> |
            </template>
            Load time: <span class="footerhighlight">{{ loadTime }}s</span> / Mako: <span class="footerhighlight">{{ makoTime }}s</span> |
            Branch: <span class="footerhighlight">{{ config.branch }}</span> |
            Now: <span class="footerhighlight">{{ nowInUserPreset }}</span>
        </div>
    </div>
</footer>
<!-- END FOOTER -->
</script>
<%!
    import json
    from time import time

    from medusa.app import backlog_search_scheduler, daily_search_scheduler
    from medusa.helper.common import pretty_file_size
    from medusa.show.show import Show

    mem_usage = None
    try:
        from psutil import Process
        from os import getpid
        mem_usage = 'psutil'
    except ImportError:
        try:
            import resource  # resource module is unix only
            mem_usage = 'resource'
        except ImportError:
            pass
%>
<script>
Vue.component('app-footer', {
    template: '#app-footer-template',
    data() {
        <%
            stats = Show.overall_stats()
            timeleft_daily = str(daily_search_scheduler.timeLeft()).split('.')[0]
            timeleft_backlog = str(backlog_search_scheduler.timeLeft()).split('.')[0]
            loadtime = '%.4f' % (time() - sbStartTime)
            makotime = '%.4f' % (time() - makoStartTime)

            if not mem_usage:
                memory = ''
            elif mem_usage == 'resource':
                memory = pretty_file_size(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)
            elif mem_usage == 'psutil':
                memory = pretty_file_size(Process(getpid()).memory_info().rss)
        %>
        return {
            // Python conversions
            loggedIn: ${json.dumps(loggedIn)},
            stats: ${json.dumps(stats)},
            timeLeft: {
                daily: ${json.dumps(timeleft_daily)},
                backlog: ${json.dumps(timeleft_backlog)},
            },
            loadTime: ${json.dumps(loadtime)},
            makoTime: ${json.dumps(makotime)},
            memoryUsage: ${json.dumps(memory)},
        };
    },
    computed: Object.assign(store.mapState(['statuses']), {
        episodePercentage() {
            const { stats } = this;
            const { episodes } = stats;
            const { total, downloaded } = episodes;
            if (total === 0) return '';
            const [ integer, fractional ] = String((downloaded / total) * 100).split('.');
            return integer + '.' + fractional.slice(0, 1) + '%';
        },
        nowInUserPreset() {
            const { config, formatDateUsingPythonPreset } = this;
            const { datePreset, timePreset } = config;
            return formatDateUsingPythonPreset(new Date(), datePreset + ' ' + timePreset);
        },
    }),
    methods: {
        formatDateUsingPythonPreset(date, preset) {
            const presetConversion = {
                '%a': 'ddd', // Weekday name, short
                '%A': 'dddd', // Weekday name, full
                '%w': 'd', // Weekday number
                '%d': 'DD', // Day of the month, zero-padded
                '%b': 'MMM', // Month name, short
                '%B': 'MMMM', // Month name, short
                '%m': 'MM', // Day of the month, zero-padded
                '%y': 'YY', // Year without century, zero-padded
                '%Y': 'YYYY', // Year with century
                '%H': 'HH', // Hour (24-hour clock), zero-padded
                '%I': 'hh', // Hour (12-hour clock), zero-padded
                '%p': 'A', // AM / PM
                '%M': 'mm', // Minute, zero-padded
                '%S': 'ss', // Second, zero-padded
                '%f': '', // [UNSUPPORTED] Microsecond, zero-padded
                '%z': 'ZZ', // UTC offset in the form +HHMM or -HHMM
                '%Z': '', // [UNSUPPORTED] Time zone name
                '%j': 'DDDD', // Day of the year, zero-padded
                '%U': '', // [UNSUPPORTED] Week number of the year (Sunday as the first day of the week), zero padded
                '%W': 'W', // Week number of the year (Monday as the first day of the week)
                '%c': date.toLocaleString(), // [APPROXIMATE] Locale's appropriate date and time representation
                '%x': date.toLocaleDateString(), // [APPROXIMATE] Locale's appropriate date representation
                '%X': date.toLocaleTimeString(), // [APPROXIMATE] Locale's appropriate time representation
                '%%': '%' // Literal '%' character
            };
            let newPreset = preset;
            for (key in presetConversion) {
                newPreset = newPreset.replace(key, presetConversion[key]);
            }
            return dateFns.format(date, newPreset);
        }
    }
});
</script>
