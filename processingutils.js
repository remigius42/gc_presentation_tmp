var ProcessingUtils = ProcessingUtils || (function () {
    var ProcessingUtils = {};

    ProcessingUtils.isSlideHavingState = function isSlideHavingState(stateName) {
	return Reveal.getCurrentSlide().getAttribute("data-state") === stateName;
    }

    ProcessingUtils.getFragmentIndex = function getFragmentIdx(event) {
	return parseInt(event.fragment.getAttribute("data-fragment-index"), 10);
    }

    ProcessingUtils.addAsyncLoadOnStateOfPdeToCanvas = function(stateName, pdeUrl, canvasId) {

	Reveal.addEventListener(stateName, function() {

	    var heapcanvas = document.getElementById(canvasId);

	    if (!Processing.getInstanceById(canvasId)) {
		var request = new XMLHttpRequest();
		request.open("GET", pdeUrl);
		request.addEventListener("load", function(event) {
		    processing = new Processing(canvasId, request.responseText);
		    processing.activate();
		});
		request.send();
	    } else {
		Processing.getInstanceById(canvasId).setup();
	    }
	}, false );
    }
    
    ProcessingUtils.registerFragmentHandler = function(canvasId, slideStateName) {
	Reveal.addEventListener( 'fragmentshown', function( event ) {
	    if (ProcessingUtils.isSlideHavingState(slideStateName)) {
		Processing.getInstanceById(canvasId).activateAnimationsForFragmentIndex(ProcessingUtils.getFragmentIndex(event));
	    }
	} );
    }

    return ProcessingUtils;
})();

