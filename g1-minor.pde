// Pressing Control-R will render this sketch.

class Animation {
    boolean isActive = true;
    function anima;
    Object target;
    double currentValue;
    double endValue;
    int millisLeft;
    int waitMillis = 0;
    int initialFrameRate = 20;
    
    Animation(target, anima, startValue, endValue, durationMillis, waitMillis, initialFrameRate, isActive) {
        this.anima = anima;
        this.target = target;
        this.currentValue = startValue;
        this.endValue = endValue;
        this.millisLeft = durationMillis;
        this.waitMillis = waitMillis;
        this.initialFrameRate = initialFrameRate;
        this.isActive = isActive;
    }
    
    public void activate() {
        isActive = true;
    }
    
    public void animate() {
        if (isActive && currentValue != endValue) {
            double currentFrameRate = frameCount > 10 ? frameRate : initialFrameRate;
            double deltaMillis = 1000.0 / currentFrameRate;
            
            if (waitMillis <= 0) {
                double framesLeft = currentFrameRate * millisLeft / 1000.0;
                double delta = (endValue - currentValue) / framesLeft; 
            
                if (abs(endValue - currentValue) < delta) {
                    currentValue = endValue;
                } else {
                    currentValue = currentValue + delta;
                    if ((delta > 0 && currentValue > endValue)
                    || (delta < 0 && currentValue < endValue)) {
                        currentValue = endValue;
                    }
                }
           
                millisLeft = millisLeft - deltaMillis;
                anima.call(target, currentValue);
            } else {
                waitMillis = waitMillis - deltaMillis;
            }
        }
    }
}

interface Drawable() {
    void draw();
}

class Shape implements Drawable {
    public int x = 0;
    public int y = 0;
    public int width = 50;
    public int height = 30;
    public int color = #ffffff;
    public int alpha = 255;
    public boolean isOutlined = true;
    public int outlineColor = #000000;
    ArrayList children = new ArrayList();

    Shape (int x, int y, int width, int height, int color, int alpha) {
        this(x, y, width, height, color, alpha, false, #000000);
    }

    Shape (int x, int y, int width, int height, int color, int alpha, boolean isOutlined, int outlineColor) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.color = color;
        this.alpha = alpha;
        this.isOutlined = isOutlined;
        this.outlineColor = outlineColor;
    }

    public void draw() {
        drawSelf();
        drawChildren();
    }
    
    void drawShape() {}
    
    void fitChild(Shape child) {
        var parentPadding = isOutlined ? 1 : 0;
        var childMargin = child.isOutlined ? 1 : 0;
        
        if (child.x + child.width + parentPadding + childMargin > width) {
            child.width = width - child.x - parentPadding - childMargin;
        }
        if (child.y + child.height + parentPadding + childMargin > height) {
            child.height = height - child.y - parentPadding - childMargin;
        }
        
        child.x = x + parentPadding + child.x;
        child.y = y + parentPadding + child.y;
        
        addChild(child);
        
        return child;
    }
    
    void addChild(Shape child) {
        children.add(child);
        return child;
    }
    
    private void drawSelf() {
        if (isOutlined) {
            stroke(outlineColor);
        } else {
            noStroke();
        }
        fill(color, alpha);
        drawShape();
    }
    
    private void drawChildren() {
        for (int i = 0; i < children.size(); i++) {
            children.get(i).draw();
        }
    }
}

class Box extends Shape {
    Box(int x, int y, int width, int height, int color, int alpha) {
        this(x, y, width, height, color, alpha, false, #000000);    
    }
    
    Box(int x, int y, int width, int height, int color, int alpha, boolean isOutlined, int outlineColor) {
        super(x, y, width, height, color, alpha, isOutlined, outlineColor);
    }
    
    void drawShape() {
        rect(x, y , width, height);
    }
}

function isInPresentation() {
    return typeof(Reveal) !== "undefined";
}

void activate() {
    frameRate(rate);
    loop();
}

void deactivate() {
    frameRate(0);
    noLoop();
}

void activateAnimations(ArrayList animations) {
    for (int i = 0; i < animations.size(); i++) {
        animations.get(i).activate();
    }
}

void activateAnimationsForFragmentIndex(index) {
    activateAnimations(fragmentAnimations.get(index));
}

class G1Region extends Box {

    int outlineOffset = 1;
    String label;
    Box contents;
    int occupiedColor;
    int contentsAlpha = 255;
    double contentsAlphaCoefficient = 1/2;
    
    G1Region(x, y, sideLength, label, freeColor, occupiedColor, alpha) {
	super(x, y, sideLength, sideLength, freeColor, alpha, true, #000000);

	this.label = label;
	this.occupiedColor = occupiedColor;
	setOccupancy(0);
    }

    void setOccupancy(fillFactor) {
	int maxHeight = getContentMaxHeight();

	children.clear();
	contents = fitChild(new Box(0, ceil(maxHeight * (1 - fillFactor)),
				    width, maxHeight * fillFactor, occupiedColor, contentsAlpha * contentsAlphaCoefficient));
    }

    double getOccupancy() {
    	return contents.height / getContentMaxHeight();
    }

    void setContentsAlpha(alpha) {
	contents.alpha = alpha * contentsAlphaCoefficient;
	contentsAlpha = alpha;
    }
    
    void drawShape() {
	super.drawShape();
	drawLabel();
    }

    private int getContentMaxHeight() {
    	return height - outlineOffset;
    }

    private void drawLabel() {
	fill(#000000, contentsAlpha);
	textAlign(CENTER, CENTER);
	textFont(font, width * 1/2);
	text(label, x, y, width, height);
    }
}

class G1Heap {

    ArrayList regions;
    int regionsWide = 10;
    int regionsHigh = 3;
    int sideLength = 20;
    int freeColor;
    int occupiedColor;
    Box container;
    int spacing = 3;
    
    G1Heap(regionsWide, regionsHigh, sideLength, freeColor, occupiedColor, container, spacing) {
	this.regionsWide = regionsWide;
	this.regionsHigh = regionsHigh;
	this.sideLength = sideLength;
	this.freeColor = freeColor;
	this.occupiedColor = occupiedColor;
	this.container = container;
	this.spacing = spacing;

	regions = new ArrayList();

	for (int y = 0; y < this.regionsHigh; y++) {
	    for (int x = 0; x < this.regionsWide; x++) {
		G1Region currRegion = new G1Region(x * (sideLength + spacing), y * (sideLength + spacing),
						   sideLength - 1, "", freeColor, occupiedColor, 255);
		G1Region currRegion = container.fitChild(currRegion);
		regions.add(currRegion);
	    }
	}
    }

    void getRegion(x, y) {
	return regions.get(y * regionsWide + x);
    }

    void updateRegionLabels() {
	var labels = Array.prototype.slice.call(arguments);

	for (int i = 0; i < labels.length; i++) {
	    if (labels[i] !== "") {
		regions.get(i).label = labels[i];
		regions.get(i).setOccupancy(0.1 + Math.random() * 0.9);
	    }
	}
    }
}

ArrayList drawables = new ArrayList();
ArrayList animations = new ArrayList();
ArrayList firstFragmentAnimations = new ArrayList();
ArrayList secondFragmentAnimations = new ArrayList();
ArrayList thirdFragmentAnimations = new ArrayList();
Font font = loadFont("FFScala.ttf");

int rate = 20;

int regionsWide = 13;
int regionsHigh = 3;
int regionSideLength = 25;
int spacing = 3;

int heapHeight = regionsHigh * regionSideLength + (regionsHigh - 1) * spacing;
int heapOffsetX = heapHeight * 0.1;
int heapOffsetY = heapHeight * 0.1;
int heapSize = regionsWide * (regionSideLength + spacing) - spacing;
int width = heapSize + 2 * heapOffsetX;
int height = heapHeight + 2 * heapOffsetY;


int backgroundColor = #eeeeee;
int heapColor = #dddddd;
int lineColor = #222222;
int freeHeapColor = heapColor;
int occupiedHeapColor = #555555;

Box heapContainer;
G1Heap g1Heap;

Animation addInactiveAnimation(target, anima, startValue, endValue, durationMillis, waitMillis) {
    Animation animation = new Animation(target, anima, startValue, endValue, durationMillis, waitMillis, rate, false);
    animations.add(animation);
    return animation;
}

void setup() {  
    background(backgroundColor);
    size(width, height);
    frameRate(rate);
    loop();
    
    
    drawables = new ArrayList();
    animations = new ArrayList();
    firstFragmentAnimations = new ArrayList();
    secondFragmentAnimations = new ArrayList();
    thirdFragmentAnimations = new ArrayList();
    forthFragmentAnimations = new ArrayList();
    fragmentAnimations = new ArrayList();
    
    heapContainer = new Box(heapOffsetX, heapOffsetY, heapSize, heapHeight, heapColor, 255 / 2, false, #000000);
    drawables.add(heapContainer);

    g1Heap = new G1Heap(regionsWide, regionsHigh, regionSideLength, freeHeapColor, occupiedHeapColor, heapContainer, 3);
    g1Heap.updateRegionLabels("E", "", "S", "", "", "", "O", "", "E", "", "", "O", "",
			"", "O", "E", "", "O", "", "O", "O", "O", "E", "", "", "",
			"", "S", "", "", "", "O", "", "", "O", "", "", "O", "");
    
    addAnimations();

    if (!isInPresentation()) {
        for (int i = 0; i < animations.size(); i++) {
            animations.get(i).activate();
        }
    }
}

void addAnimations() {
    int waitEdenFillDuration = 0;
    int edenFillDuration = 2000;
    var changeOccupancyFunction = function(occupancy) { this.setOccupancy(occupancy); };
    for (int i = 0; i < g1Heap.regions.size(); i++) {
	G1Region currentRegion = g1Heap.regions.get(i);
	if (currentRegion.label === "E") {
	    firstFragmentAnimations.add(addInactiveAnimation(currentRegion, changeOccupancyFunction,
							     currentRegion.getOccupancy(), 0.95,
							     edenFillDuration, waitEdenFillDuration));
	}
    }

    int waitEdenCleanDuration = isInPresentation() ? 0 : waitEdenFillDuration + edenFillDuration;
    int edenCleanDuration = 2000;
    var changeInteriorAlphaFunction = function(alpha) { this.setContentsAlpha(alpha); };
    for (int i = 0; i < g1Heap.regions.size(); i++) {
	G1Region currentRegion = g1Heap.regions.get(i);
	if (currentRegion.label === "E") {
	    secondFragmentAnimations.add(addInactiveAnimation(currentRegion, changeInteriorAlphaFunction,
							      currentRegion.contentsAlpha, 0,
							      edenCleanDuration, waitEdenCleanDuration));
	}
    }

    int waitSurvivorCleanDuration = isInPresentation() ? 0 : waitEdenCleanDuration + edenCleanDuration;
    int survivorCleanDuration = 2000;
    for (int i = 0; i < g1Heap.regions.size(); i++) {
	G1Region currentRegion = g1Heap.regions.get(i);
	if (currentRegion.label === "S") {
		thirdFragmentAnimations.add(addInactiveAnimation(currentRegion, changeInteriorAlphaFunction,
							      currentRegion.contentsAlpha, 0,
							      survivorCleanDuration, waitSurvivorCleanDuration));
	}
    }
    G1Region newSurvivorRegion = g1Heap.getRegion(3, 1);
    var setupNewSurviorRegionFunction = function() {newSurvivorRegion.contentsAlpha = 0; newSurvivorRegion.label = "S"; newSurvivorRegion.setOccupancy(0.6);}
    thirdFragmentAnimations.add(addInactiveAnimation(newSurvivorRegion, setupNewSurviorRegionFunction,
						    0, 1, 0, waitSurvivorCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(newSurvivorRegion, changeInteriorAlphaFunction,
 						     0, 255,
						     survivorCleanDuration, waitSurvivorCleanDuration));

    fragmentAnimations.add(firstFragmentAnimations);
    fragmentAnimations.add(secondFragmentAnimations);
    fragmentAnimations.add(thirdFragmentAnimations);
}

void draw() {
    background(backgroundColor);
    
    for (int i = 0; i < drawables.size(); i++) {
        drawables.get(i).draw();
    }
    
    for (int i = 0; i < animations.size(); i++) {
        animations.get(i).animate();
    }
}
