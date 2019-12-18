import milchreis.imageprocessing.*;
import processing.video.*;

PImage desired, current;
int imageSize = 500;
int idx = 10;
// This is the cooking goal reference photo of recipe/step
int ref = 1;

// Variable for capture device
Capture foodScreenshot;

void setup() {
  size(500, 500);
  background (0);
  //displaying available cameras
  String[] cameras = Capture.list();
  printArray(cameras);
  foodScreenshot = new Capture(this, 640, 480, cameras[1]);
  foodScreenshot.start();
  textAlign(CENTER, CENTER);
  textSize(28);
  fill(255);
  text("Start cooking!", width/2,height/2);
}

void captureEvent(Capture foodScreenshot) {
  foodScreenshot.read();
}

void mousePressed() {
  idx++;
  foodScreenshot.save("data/"+idx+".png");
  compareFoodColors(idx);
}

// Switch between reference photos: curry steps 12345; tea types 67890
void keyPressed()
{
   ref = key-48; 
  println(ref); 
}

void draw() {
  //  image(foodScreenshot, 0, 0);
}

void compareFoodColors(int idx) {
  // Create desired image
  CreateImageFromColor(loadImage(dataPath(ref+".jpg")), ref);
  // Load desired image
  desired = loadImage(dataPath("my"+ref+".jpg"));
  // Create current image
  CreateImageFromColor(loadImage(dataPath(idx+".png")), idx);
  // Load current image
  current = loadImage(dataPath("my"+idx+".jpg"));

  // Calculate a picture with different pixels
  // white is a big difference
  // black is less/no difference
  PImage differenceImage = Comparison.calculateDifferenceImage(desired, current);
  image(differenceImage, 0, 0);
  image(desired.get(0, 0, desired.width/2, desired.height/2), 0, 0);
  image(current.get(0, 0, current.width/2, current.height/2), width/2, 0);

  float difference = Comparison.howDifferent(desired, current);
  float differenceInPercent = difference * 100;

  // the following 2 lines are lerpColor option
  color deltaColor = lerpColor(desired.get(0, 0), current.get(0, 0), 0.4);
  fill(deltaColor);

  // the following 3 lines is hue option    
  // colorMode(HSB, 255);
  // color c = color(colorDist(desired.get(0, 0), current.get(0, 0)), 145, 155);
  // fill(c+current.get(0, 0));
  
  rect(0, height*0.75, width, height/4);
  fill(255);
  text("Goal", width/4, height/4);
  text("Now", width*0.75, height/4);
  text("Add this color", width/2, height*0.87);
  text("Difference:" + nf(differenceInPercent, 0, 1) + "%", width/2, height*0.62);
}

//Calculate HSB color to match
//float colorDist(color c1, color c2)
//{
//  float avghue = (hue(c1) + hue(c2))/2;
//  float distance = abs(hue(c2)-avghue);
//  println(distance);
//  return distance;
//} // colorDist()

void CreateImageFromColor(PImage img, int k) {
  colorMode(RGB);
  PImage colorImage = createImage(500, 500, RGB);
  colorImage.loadPixels();

  PImage newImg = img.get(0, 0, imageSize, imageSize);
  color imageColor = extractColorFromImage(newImg);
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      colorImage.set(i, j, imageColor);
    }
  }
  colorImage.updatePixels();
  image(colorImage, 0, 0);
  colorImage.save("data/my"+k+".jpg");
}  // CreateImageFromColor

color extractColorFromImage(final PImage img) {
  img.loadPixels();
  color r = 0, g = 0, b = 0;

  for (final color c : img.pixels) {
    r += c >> 020 & 0xFF;
    g += c >> 010 & 0xFF;
    b += c        & 0xFF;
  }

  r /= img.pixels.length;
  g /= img.pixels.length;
  b /= img.pixels.length;

  return color(r, g, b);
}  // extractColorFromImage
