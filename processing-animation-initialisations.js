(function init() {

    function initAnimation(animationName) {
	ProcessingUtils.addAsyncLoadOnStateOfPdeToCanvas(animationName, animationName + '.pde', animationName + '-canvas');
	ProcessingUtils.registerFragmentHandler(animationName + '-canvas', animationName);
    }

    initAnimation('mainjob');
    initAnimation('generational');
    initAnimation('throughput-minor');
    initAnimation('throughput-major');
    initAnimation('cms-concurrent');
    initAnimation('g1-minor');
    initAnimation('g1-marking');
    initAnimation('g1-mixed');
})();

