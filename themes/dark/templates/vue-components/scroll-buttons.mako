<script type="text/x-template" id="scroll-buttons-template">
<div id="scroll-buttons-wrapper">
    <div class="scroll-wrapper top" :class="{ show: showToTop }" @click.prevent="scrollTop">
        <span class="scroll-top-inner">
            <i class="glyphicon glyphicon-circle-arrow-up"></i>
        </span>
    </div>

    <div class="scroll-wrapper left" :class="{ show: showLeftRight }">
        <span class="scroll-left-inner">
            <i @click.prevent="scrollLeft" class="glyphicon glyphicon-circle-arrow-left"></i>
        </span>
    </div>

    <div class="scroll-wrapper right" :class="{ show: showLeftRight }">
        <span class="scroll-right-inner">
            <i @click.prevent="scrollRight" class="glyphicon glyphicon-circle-arrow-right"></i>
        </span>
    </div>
</div>
</script>
<script>
Vue.component('scroll-buttons', {
    template: '#scroll-buttons-template',
    data() {
        return {
            showToTop: false,
            showLeftRight: false
        };
    },
    methods: {
        scrollTop() {
            const { scrollTo } = this;
            scrollTo($('body'));
        },
        scrollLeft() {
            $('div.horizontal-scroll').animate({
                scrollLeft: '-=153'
            }, 1000, 'easeOutQuad');
        },
        scrollRight() {
            $('div.horizontal-scroll').animate({
                scrollLeft: '+=153'
            }, 1000, 'easeOutQuad');
        },
        /**
         * Make an attempt to detect if there are currently scroll bars visible for divs with the horizontal-scroll class.
         *
         * If scroll bars are visible the fixed left and right buttons become visible on that page.
         */
        initHorizontalScroll() {
            const scrollDiv = $('div.horizontal-scroll').get();
            if (scrollDiv.length === 0) {
                return;
            }

            const scrollbarVisible = scrollDiv.map(el => {
                return (el.scrollWidth > el.clientWidth);
            }).indexOf(true);

            if (scrollbarVisible >= 0) {
                this.showLeftRight = true;
            } else {
                this.showLeftRight = false;
            }
        },
        scrollTo(dest) {
            $('html, body').animate({ scrollTop: $(dest).offset().top }, 500, 'linear');
        }
    },
    mounted() {
        const { initHorizontalScroll } = this;

        initHorizontalScroll();

        $(window).on('resize', () => {
            initHorizontalScroll();
        });

        $(document).on('scroll', () => {
            if ($(window).scrollTop() > 100) {
                this.showToTop = true;
            } else {
                this.showToTop = false;
            }
        });
    }
});
</script>
<style>
.scroll-wrapper {
    position: fixed;
    opacity: 0;
    visibility: hidden;
    overflow: hidden;
    text-align: center;
    font-size: 20px;
    z-index: 999;
    background-color: #777;
    color: #eee;
    width: 50px;
    height: 48px;
    line-height: 48px;
    right: 30px;
    bottom: 30px;
    padding-top: 2px;
    border-radius: 10px;
    -webkit-transition: all 0.5s ease-in-out;
    -moz-transition: all 0.5s ease-in-out;
    -ms-transition: all 0.5s ease-in-out;
    -o-transition: all 0.5s ease-in-out;
    transition: all 0.5s ease-in-out;
}
</style>
