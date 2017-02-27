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
    
    void getInnerWidth() {
        return width - (isOutlined ? 1 : 0);
    }
    
    void getInnerHeight() {
        return height - (isOutlined ? 1 : 0);
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

ArrayList drawables = new ArrayList();
ArrayList animations = new ArrayList();
ArrayList firstFragmentAnima = new ArrayList();
ArrayList secondFragmentAnima = new ArrayList();
ArrayList thirdFragmentAnima = new ArrayList();
ArrayList fragmentAnimations = new ArrayList();
Font font = loadFont("FFScala.ttf");

int rate = 20;
int heapHeight = 50;
int width = isInPresentation() ? Reveal.getConfig().width * 0.9 : 300;
int heapOffsetX = heapHeight*0.1;
int heapSize = width - 2 * heapOffsetX;
int height = isInPresentation() ? heapHeight * 2 + heapOffsetY * 2 : 300;
int heapOffsetY = heapHeight*0.1;

int backgroundColor = #eeeeee;
int heapColor = #dddddd;
int lineColor = #222222;
int freeHeapColor = heapColor;
int occupiedHeapColor = #555555;

Box heap;

Box createHeapBox(int x, int width) {
    Box box = new Box(x, 0, width, heapHeight, occupiedHeapColor, 255);
    return box;
}

Animation addInactiveAnimation(target, anima, startValue, endValue, durationMillis, waitMillis, rate) {
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
    firstFragmentAnima = new ArrayList();
    secondFragmentAnima = new ArrayList();
    thirdFragmentAnima = new ArrayList();
    fragmentAnimations = new ArrayList();
    
    heap = new Box(heapOffsetX, heapOffsetY, heapSize, heapHeight, heapColor, 255, true, #000000);
    drawables.add(heap);
    
    int heapInnerWidth = heap.getInnerWidth();
    
    Box staying1 = heap.fitChild(createHeapBox(0, ceil(heapInnerWidth/3 * 2/3)));
    Box removable1 = heap.fitChild(createHeapBox(floor(heapInnerWidth/3 * 2/3), ceil(heapInnerWidth/3 * 1/3)));
    
    var offset = floor(1/3 * heapInnerWidth);
    Box staying2 = heap.fitChild(createHeapBox(offset, ceil(heapInnerWidth/3 * 1/3)));
    Box removable2 = heap.fitChild(createHeapBox(offset + staying2.width, ceil(heapInnerWidth/3 * 2/3)));
    
    offset = floor(2/3 * heapInnerWidth);
    Box staying3 = heap.fitChild(createHeapBox(offset, ceil(heapInnerWidth/3 * 1/4)));
    Box removable3 = heap.fitChild(createHeapBox(offset + staying3.width, ceil(heapInnerWidth/3 * 1/5)));
    
    Box scanner = heap.fitChild(new Box(-2, 0, 2, heapHeight, lineColor, 255));
    
    
    int scanDuration = 2000;
    firstFragmentAnima.add(addInactiveAnimation(scanner, function(value)  {this.x = value}, scanner.x, heapSize, scanDuration, 0, rate));   firstFragmentAnima.add(addInactiveAnimation(scanner, function(value)  {this.alpha = value}, scanner.alpha, 0, 200, scanDuration - 200, rate,  false));
    
    int waitRemoveDuration = isInPresentation() ? 0 : scanDuration + 1000;
    int removeDuration = 1000;
    secondFragmentAnima.add(addInactiveAnimation(removable1,  function(value) {this.alpha = value}, removable1.alpha, 0,  removeDuration, waitRemoveDuration, rate, false));
    secondFragmentAnima.add(addInactiveAnimation(removable2,  function(value) {this.alpha = value}, removable2.alpha, 0,  removeDuration, waitRemoveDuration, rate, false));
    secondFragmentAnima.add(addInactiveAnimation(removable3,  function(value) {this.alpha = value}, removable3.alpha, 0,  removeDuration, waitRemoveDuration, rate, false));
    
    int waitMoveDuration = isInPresentation() ? 0 : waitRemoveDuration + removeDuration + 1000;
    int moveDuration = 1000;
    thirdFragmentAnima.add(addInactiveAnimation(staying2, function(value)  {this.x = value}, staying2.x, removable1.x, moveDuration,  waitMoveDuration, rate, false));
    thirdFragmentAnima.add(addInactiveAnimation(staying3, function(value)  {this.x = value}, staying3.x, removable1.x + staying2.width,  moveDuration, waitMoveDuration, rate, false));

    fragmentAnimations.add(firstFragmentAnima);
    fragmentAnimations.add(secondFragmentAnima);
    fragmentAnimations.add(thirdFragmentAnima);
    
    if (!isInPresentation()) {
        for (int i = 0; i < animations.size(); i++) {
            animations.get(i).activate();
        }
    }
}

void draw() {
    background(#eeeeee);
    
    for (int i = 0; i < drawables.size(); i++) {
        drawables.get(i).draw();
    }
    
    drawLabels();
    
    for (int i = 0; i < animations.size(); i++) {
        animations.get(i).animate();
    }
}

void drawLabels() {
    int memoryLabelSize = (int) (heapHeight * 2/3);
    int insideHeapLabelSize = (int) (heapHeight / 2);
    fill(lineColor);
    textAlign(CENTER, TOP);
    textFont(font, memoryLabelSize);
    text("Memory", heapOffsetX, heapOffsetY + heapHeight, heapSize, heapHeight);
    
    fill(freeHeapColor);
    textAlign(LEFT, CENTER);
    textFont(font, insideHeapLabelSize);
    text("Occupied", heapOffsetX + 2, heapOffsetY, heapSize, heapHeight);
    
    fill(occupiedHeapColor);
    textAlign(RIGHT, CENTER);
    textFont(font, insideHeapLabelSize);
    text("Free", heapOffsetX, heapOffsetY, heapSize - 2, heapHeight);
}

