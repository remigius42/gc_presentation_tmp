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

    public void traverse(func) {
        func.call(this);
        
        for(int i = 0; i < children.size(); i++) {
            children.get(i).traverse(func);
        }
    }

    public void draw() {
        traverse(function() { this.drawSelf(); });
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
            stroke(outlineColor, alpha);
        } else {
            noStroke();
        }
        fill(color, alpha);
        drawShape();
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

class GenerationalHeap {
    public double newRatio = 1/3;
    public double survivorRatio = 8;
    public Box container = null;
    public int spacing = 6;
    
    public Box eden, edenContents, survivor1, survivor1Contents, survivor2, survivor2Contents, old, oldContents;
    
    GenerationalHeap(newRatio, survivorRatio, container, spacing) {
        this.newRatio = newRatio;
        this.survivorRatio = survivorRatio;
        this.container = container;
        this.spacing = spacing;
    
        var heapSizeMinusSpacing = heapSize - 3 * spacing;
        var newSize = heapSizeMinusSpacing * newRatio;    
        var survivorWidth = newSize / (survivorRatio + 2);
    
        var edenWidth = newSize - 2 * survivorWidth;
        eden = container.fitChild(createHeapBoxWithBorder(0, edenWidth, #000000));
        edenContents = eden.fitChild(createHeapBox(0, edenWidth / 2));
    
        var survivor1Offset = edenWidth + spacing;
        survivor1 = container.fitChild(createHeapBoxWithBorder(survivor1Offset, survivorWidth, #000000));
        survivor1Contents = survivor1.fitChild(createHeapBox(0, 0));
    
        var survivor2Offset = survivor1Offset + survivorWidth + spacing;
        survivor2 = container.fitChild(createHeapBoxWithBorder(survivor2Offset, survivorWidth, #000000));
        survivor2Contents = survivor2.fitChild(createHeapBox(0, survivorWidth / 2));
    
        var oldOffset = survivor2Offset + survivorWidth + spacing;
        old = container.fitChild(createHeapBoxWithBorder(oldOffset, heapSize - oldOffset, #000000));
        oldContents = old.fitChild(createHeapBox(0, heapSize/3));
    }
    
    void setAlpha(int alpha) {
        container.traverse(function() { this.alpha = alpha; });
    }
    
    private Box createHeapBoxWithBorder(int x, int width, color) {
        Box box = new Box(x, 0, width, heapHeight, freeHeapColor, 255, true, color);
        return box;
    }

    private Box createHeapBox(int x, int width) {
        Box box = new Box(x, 0, width, heapHeight, occupiedHeapColor, 255);
        return box;
    }
}

ArrayList drawables = new ArrayList();
ArrayList animations = new ArrayList();
ArrayList firstFragmentAnimations = new ArrayList();
ArrayList secondFragmentAnimations = new ArrayList();
ArrayList thirdFragmentAnimations = new ArrayList();
ArrayList fragmentAnimations = new ArrayList();
Font font = loadFont("FFScala.ttf");

int rate = 20;

int heapHeight = 50;
int width = isInPresentation() ? Reveal.getConfig().width * 0.9 : 300;
int heapOffsetX = heapHeight * 0.1;
int heapSize = width - 2 * heapOffsetX;
int height = isInPresentation() ? heapHeight * 3/2 + heapOffsetY * 2 : 300;
int heapOffsetY = heapHeight * 0.1;

int backgroundColor = #eeeeee;
int heapColor = #dddddd;
int lineColor = #222222;
int freeHeapColor = heapColor;
int occupiedHeapColor = #555555;

Box heapContainer;
Box wholeHeap, oldYoungHeap, youngBox, oldYoungWithEdenHeap;
GenerationalHeap generationalHeap;
int heapLabelAlpha, edenLabelAlpha, s1LabelAlpha, s2LabelAlpha, oldLabelAlpha, youngLabelAlpha;

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
    firstFragmentAnimations = new ArrayList();
    secondFragmentAnimations = new ArrayList();
    thirdFragmentAnimations = new ArrayList();
    fragmentAnimations = new ArrayList();
    
    edenLabelAlpha = s1LabelAlpha = s2LabelAlpha = oldLabelAlpha = youngLabelAlpha = 0;
    heapLabelAlpha = 255;
    var spacing = 6;
    
    var hideFun = function() {this.alpha = 0;};
    
    heapContainer = new Box(heapOffsetX, heapOffsetY, heapSize, heapHeight, heapColor, 255/2, false, #000000);
    drawables.add(heapContainer);
    
    wholeHeap = heapContainer.fitChild(new Box(0, 0, heapContainer.width, heapContainer.height, occupiedHeapColor, 255, true, #000000));
    
    oldYoungHeap = heapContainer.fitChild(new Box(0, 0, heapSize, heapHeight, heapColor, 255 / 2, false, #000000));
    youngBox = oldYoungHeap.fitChild(new Box(0, 0, heapSize / 3 - spacing / 2, heapHeight, occupiedHeapColor, 255, true, #000000));
    oldBox = oldYoungHeap.fitChild(new Box(heapSize / 3 + spacing /2, 0, heapSize, heapHeight, occupiedHeapColor, 255, true, #000000));
    oldYoungHeap.traverse(hideFun);
    
    int newRatio = 1/3;
    int survivorRatio = 8;
    int newSize = heapSize * newRatio;
    int survivorTotalWidth = newSize / (2 + survivorRatio) * 2;
    oldYoungWithEdenHeap = heapContainer.fitChild(new Box(0, 0, heapSize, heapHeight, heapColor, 255 / 2, false, #000000));
    edenBox = oldYoungWithEdenHeap.fitChild(new Box(0, 0, newSize - survivorTotalWidth - spacing/2, heapHeight, occupiedHeapColor, 255, true, #000000));
    remainingYoung = oldYoungWithEdenHeap.fitChild(new  Box(newSize - survivorTotalWidth + spacing/2, 0, survivorTotalWidth - spacing, heapHeight, occupiedHeapColor,  255, true, #000000));
    old = oldYoungWithEdenHeap.fitChild(new Box(heapSize / 3 + spacing /2, 0,  heapSize, heapHeight, occupiedHeapColor, 255, true, #000000));
    oldYoungWithEdenHeap.traverse(hideFun);
    
    generationalHeapContainer = heapContainer.fitChild(new Box(0, 0, heapSize, heapHeight, heapColor, 255 / 2, false, #000000));
    generationalHeap = new GenerationalHeap(newRatio, survivorRatio, generationalHeapContainer, spacing);
    generationalHeap.edenContents.width = generationalHeap.eden.width - 1;
    generationalHeap.survivor2Contents.width = generationalHeap.survivor2.width - 1;
    generationalHeap.oldContents.width = generationalHeap.old.width - 1;
    generationalHeap.setAlpha(0);

    addAnimations();

    if (!isInPresentation()) {
        for (int i = 0; i < animations.size(); i++) {
            animations.get(i).activate();
        }
    }
}

void addAnimations() {
    int oldYoungDuration = 2000;
    firstFragmentAnimations.add(addInactiveAnimation(wholeHeap,  function(value)   { this.alpha = value}, wholeHeap.alpha, 0,  oldYoungDuration / 2, 0, rate));
    firstFragmentAnimations.add(addInactiveAnimation(null, function(value)   {heapLabelAlpha = value}, heapLabelAlpha, 0, oldYoungDuration / 2, 0, rate));
    firstFragmentAnimations.add(addInactiveAnimation(oldYoungHeap,  function(value)   {this.traverse(function() {this.alpha = value;});}, oldYoungHeap.alpha, 255, oldYoungDuration, 0, rate));
    firstFragmentAnimations.add(addInactiveAnimation(null, function(value)   {youngLabelAlpha = value;}, youngLabelAlpha, 255, oldYoungDuration, 0, rate));
    firstFragmentAnimations.add(addInactiveAnimation(null, function(value)   {oldLabelAlpha = value;},  oldLabelAlpha, 255, oldYoungDuration, 0, rate));
    
    int waitOldYoungWithEdenDuration = isInPresentation() ? 0 : oldYoungDuration + 1000;
    int oldYoungWithEdenDuration = 1000;
    secondFragmentAnimations.add(addInactiveAnimation(oldYoungHeap,   function(value)   { this.traverse(function() {this.alpha = value;});}, oldYoungHeap.alpha, 0,   oldYoungWithEdenDuration / 2, waitOldYoungWithEdenDuration, rate));
    secondFragmentAnimations.add(addInactiveAnimation(null,  function(value)   {youngLabelAlpha = value;}, 255, 0, oldYoungWithEdenDuration / 2, waitOldYoungWithEdenDuration, rate));
    secondFragmentAnimations.add(addInactiveAnimation(oldYoungWithEdenHeap,   function(value)   {this.traverse(function() {this.alpha = value;});},  oldYoungWithEdenHeap.alpha, 255, oldYoungWithEdenDuration, waitOldYoungWithEdenDuration, rate));
    secondFragmentAnimations.add(addInactiveAnimation(null,  function(value)   {edenLabelAlpha = value}, edenLabelAlpha,  255, oldYoungWithEdenDuration, waitOldYoungWithEdenDuration, rate));
    
    int waitGenerationalDuration = isInPresentation() ? 0 : waitOldYoungWithEdenDuration + oldYoungWithEdenDuration + 1000;
    int generationalDuration = 1000;
    thirdFragmentAnimations.add(addInactiveAnimation(oldYoungWithEdenHeap,    function(value)   { this.traverse(function() {this.alpha = value;});},  oldYoungWithEdenHeap.alpha, 0,   generationalDuration / 2,  waitGenerationalDuration, rate));
    thirdFragmentAnimations.add(addInactiveAnimation(generationalHeap,    function(value)   {this.setAlpha(value);},   0, 255, generationalDuration,  waitGenerationalDuration, rate));
    thirdFragmentAnimations.add(addInactiveAnimation(null,   function(value)   {s1LabelAlpha = s2LabelAlpha = value}, s1LabelAlpha,  255,  generationalDuration, waitGenerationalDuration, rate));
    
    fragmentAnimations.add(new ArrayList());
    fragmentAnimations.add(firstFragmentAnimations);
    fragmentAnimations.add(secondFragmentAnimations);
    fragmentAnimations.add(thirdFragmentAnimations);
}

void draw() {
    background(backgroundColor);
    
    for (int i = 0; i < drawables.size(); i++) {
        drawables.get(i).draw();
    }
    
   drawLabels();
    
    for (int i = 0; i < animations.size(); i++) {
        animations.get(i).animate();
    }
}

void drawHeapLabel(String labelText, Box heapBox, int alpha) {
    var marginTop = 5;
    var labelHeight = 50; 
    var generationFontSize = generationalHeap.survivor1.width; //12;
    
    fill(#000000, alpha);
    textAlign(CENTER, TOP);
    textFont(font, generationFontSize);
    text(labelText, heapBox.x, heapBox.y + heapBox.height + marginTop, heapBox.width, labelHeight);
}

void drawLabels() {
    drawHeapLabel("Heap", heapContainer, heapLabelAlpha);
    
    drawHeapLabel("Young", youngBox, youngLabelAlpha);
    
    drawHeapLabel("Eden", generationalHeap.eden, edenLabelAlpha);
    drawHeapLabel("S1", generationalHeap.survivor1, s1LabelAlpha);
    drawHeapLabel("S2", generationalHeap.survivor2, s2LabelAlpha);
    drawHeapLabel("Old", generationalHeap.old, oldLabelAlpha);
}

