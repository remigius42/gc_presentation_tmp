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
GenerationalHeap generationalHeap;
Box oldStaying1, oldRemovable1, oldStaying2, oldRemovable2, oldStaying3, oldRemovable3, oldStaying4, oldRemovable4;

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
    fragmentAnimations = new ArrayList();
    
    heapContainer = new Box(heapOffsetX, heapOffsetY, heapSize, heapHeight, heapColor, 255 / 2, false, #000000);
    drawables.add(heapContainer);
    
    generationalHeap = new GenerationalHeap(1/3, 8, heapContainer, 6);
    
    generationalHeap.edenContents.width = generationalHeap.eden.width * 0.75;
    generationalHeap.survivor2Contents.width = generationalHeap.survivor2.width * 0.75;
    generationalHeap.oldContents.width = generationalHeap.old.width * 0.8;


    var old = generationalHeap.old;
    oldStaying1 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldStaying2 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldStaying3 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldStaying4 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldRemovable1 = old.fitChild(new Box(0, 0, 50, old.height, occupiedHeapColor, 255, false, #000000));
    oldRemovable2 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldRemovable3 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));
    oldRemovable4 = old.fitChild(new Box(0, 0, 0, old.height, occupiedHeapColor, 255, false, #000000));

    addAnimations();

    if (!isInPresentation()) {
        for (int i = 0; i < animations.size(); i++) {
            animations.get(i).activate();
        }
    }
}

void addAnimations() {
    var eden = generationalHeap.edenContents;
    var survivor2 = generationalHeap.survivor2Contents;
    var old = generationalHeap.oldContents;
    var changeWidthFunction = function(value) {this.width = value};
    var changeXFunction = function(value) {this.x = value};
    var changeAlphaFunction = function(value) {this.alpha = value};
    
    int waitOldFillDuration = isInPresentation() ? 0 : 1000;
    int oldFillDuration = 2000;
    firstFragmentAnimations.add(addInactiveAnimation(eden,    changeWidthFunction,  eden.width, eden.width * 3/4,  oldFillDuration,  waitOldFillDuration));
    firstFragmentAnimations.add(addInactiveAnimation(survivor2,     changeWidthFunction,  survivor2.width, survivor2.width * 3/4,  oldFillDuration, waitOldFillDuration));
    firstFragmentAnimations.add(addInactiveAnimation(old,     changeWidthFunction,  old.width, old.width + eden.width / 4 +  survivor2.width / 4, oldFillDuration, waitOldFillDuration));
    
    int waitYoungCleanDuration = isInPresentation() ? 0 : waitOldFillDuration + oldFillDuration + 1000;
    int youngCleanDuration = 2000;
    secondFragmentAnimations.add(addInactiveAnimation(eden,   changeWidthFunction,  eden.width *3/4, 0,  youngCleanDuration,   waitYoungCleanDuration));
    secondFragmentAnimations.add(addInactiveAnimation(survivor2,    changeWidthFunction, survivor2.width *3/4,  0, youngCleanDuration,   waitYoungCleanDuration));
    
    int waitOldCleanDuration = isInPresentation() ? 0 : waitYoungCleanDuration + youngCleanDuration + 1000;
    int oldCleanDuration = 2000;
    int oldBeforeFragmentationWidth = old.width + eden.width / 4 + survivor2.width / 4;
    int staying1Width = oldBeforeFragmentationWidth / 4 * 3/4;
    int removable1Width = oldBeforeFragmentationWidth / 4 * 1/4;
    int staying2Width = oldBeforeFragmentationWidth / 4 * 2/3;
    int removable2Width = oldBeforeFragmentationWidth / 4 * 1/3;
    int staying3Width = oldBeforeFragmentationWidth / 4 * 1/5;
    int removable3Width = oldBeforeFragmentationWidth / 4 * 4/5;
    int staying4Width = oldBeforeFragmentationWidth / 4 * 5/6;
    int removable4Width = oldBeforeFragmentationWidth / 4 * 1/6;
    
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying1, changeWidthFunction, 0,   ceil(staying1Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable1,  changeWidthFunction, 0,   ceil(removable1Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying2,  changeWidthFunction, 0,   ceil(staying2Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable2,  changeWidthFunction, 0,   ceil(removable2Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying3,  changeWidthFunction, 0,   ceil(staying3Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable3,  changeWidthFunction, 0,   ceil(removable3Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying4,  changeWidthFunction, 0,   ceil(staying4Width),  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable4,  changeWidthFunction, 0,   ceil(removable4Width),  0,   waitOldCleanDuration));
    
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable1,   changeXFunction, 0, old.x +  staying1Width, 0,    waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying2,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 1/4,    staying2Width, 0,  waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable2,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 1/4 +  staying2Width,  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying3,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 2/4,  0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable3,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 2/4 +  staying3Width,   0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldStaying4,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 3/4,    0,   waitOldCleanDuration));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable4,   changeXFunction, 0, old.x + oldBeforeFragmentationWidth * 3/4 +  staying4Width,  0,   waitOldCleanDuration));
    
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable1,   changeAlphaFunction, 255,   0,  oldCleanDuration,    waitOldCleanDuration + 100));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable2,    changeAlphaFunction, 255,   0,  oldCleanDuration,     waitOldCleanDuration + 100));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable3,     changeAlphaFunction, 255,   0,  oldCleanDuration,      waitOldCleanDuration + 100));
    thirdFragmentAnimations.add(addInactiveAnimation(oldRemovable4,     changeAlphaFunction, 255,   0,  oldCleanDuration,      waitOldCleanDuration + 100));
    thirdFragmentAnimations.add(addInactiveAnimation(old,   changeAlphaFunction, old.alpha,   0,  0,    waitOldCleanDuration + 50));
    
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

void drawHeapLabel(String labelText, Box heapBox) {
    var marginTop = 5;
    var labelHeight = 50; 
    var generationFontSize = generationalHeap.survivor1.width; //12;
    
    fill(#000000);
    textAlign(CENTER, TOP);
    textFont(font, generationFontSize);
    text(labelText, heapBox.x, heapBox.y + heapBox.height + marginTop, heapBox.width, labelHeight);
}

void drawLabels() {
    drawHeapLabel("Eden", generationalHeap.eden);
    drawHeapLabel("S1", generationalHeap.survivor1);
    drawHeapLabel("S2", generationalHeap.survivor2);
    drawHeapLabel("Old", generationalHeap.old);
}

