import java.util.Map;
import java.util.Iterator;

//sound library minim
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

//kinect library
import SimpleOpenNI.*;
SimpleOpenNI context;
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();

                                                                                                 
//gloable variables. 
Minim minim;
AudioPlayer song;
AudioPlayer song1;
AudioPlayer song3;
BeatDetect beat;
BeatDetect beat1;
BeatDetect beat3;
AudioMetaData meta;
AudioMetaData meta1;
AudioMetaData meta3;


boolean mutedSong;
boolean clickPrev;
boolean clickNext; 

int randomSong = 1; 

//images
PImage foto;
PImage hand;
PImage arrowRight;
PImage arrowLeft;

float eRadius;
float t; 

float y = 350;
float xy = 2;
float X = 650;
float dx = 2;
float s = 350;
float sx = 2;
float x = 0;

float x1(float t){
  return sin(t / 10) * 100 + sin (t / 5 ) * 20;
}

float y1(float t){
  return cos(t / 10) * 100;
}

float x2(float t){
  return sin(t / 10) * 200 + sin (t) * 2;
}

float y2(float t){
  return cos(t / 20) * 200 + cos (t / 12) * 20;
}

static final int NUM_LINES = 20;


void setup()
{
  size(640, 480, P3D);
  minim = new Minim(this);
  
  clickPrev = false; 
  clickNext = false; 
  mutedSong = false;
  
  //inladen van png files
  foto = loadImage("linkin.png");
  hand = loadImage("handje.png");
  arrowRight = loadImage("arrowright.png");
  arrowLeft = loadImage("arrowleft.png");
  
  //inladen van muziek files
  song = minim.loadFile("Ten.mp3");
  song1 = minim.loadFile("Wavy.mp3");
  song3 = minim.loadFile("numb.mp3");
 
  //detecteren van de beat
  beat = new BeatDetect();
  beat1 = new BeatDetect();
  beat3 = new BeatDetect();
  
  
  meta = song.getMetaData();
  meta1 = song1.getMetaData();
  meta3 = song3.getMetaData();
  
  //kinect conectie
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }   
  
  //diepte map aanzetten
  context.enableDepth();
  
  // spiegel aanzetten
  context.setMirror(true);

  // aanzetten van hand + gestures.
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  context.startGesture(SimpleOpenNI.GESTURE_CLICK);
  

}

void draw()
{
  
  background(0);
  beat.detect(song.mix);
  strokeWeight(5); 
  
  image(arrowRight, 550, 220);
  image(arrowLeft, 30, 220);
  
  //update camera
  context.update();
 
   
 //inladen functies voor liedje + vorm  
   if (randomSong == 1 ){
     nummer1();
   } else if (randomSong == 2){
     nummer2();
   } else if (randomSong == 3){
     nummer3();
   }
   
   
  //volgen van de handpositie voor de kinect
    if(handPathList.size() > 0)
 {
   Iterator itr = handPathList.entrySet().iterator();
   while(itr.hasNext())
   {
     Map.Entry mapEntry = (Map.Entry)itr.next();
     int handId =  (Integer)mapEntry.getKey();
     ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
     PVector p;
     PVector p2d = new PVector();
       Iterator itrVec = vecList.iterator();
         while( itrVec.hasNext() )
         {
           p = (PVector) itrVec.next();
           // converteer de kinect coordinaten naar het scherm
           context.convertRealWorldToProjective(p,p2d);
           vertex(p2d.x,p2d.y);
         }
       p = vecList.get(0);
       context.convertRealWorldToProjective(p,p2d);
       point(p2d.x,p2d.y); 
       
         
      image(hand, p2d.x, p2d.y);
      
     //als de positie van de hand onder de 200 is word clickPrev true , als handpositie groter is dan 200 blijft hij false.
      if (p2d.x < 200)
      {
         clickPrev = true; 
      } else if (p2d.x > 200 && p2d.x < 400)
        {
          clickPrev = false;
        }
     
     //als de handpositie boven de 430 is word clickNext true , als de positie kleiner is dan 430 blijft hij false.
      if (p2d.x > 430)
      {
        clickNext = true; 
      } else if (p2d.x < 430)
        {
          clickNext = false; 
        }     
    }
  }
   
   
   
   
}

//eerste liedje met daarbij behorende vorm.
void nummer1() {
   
  
  //als een ander liedje aan het spelen is word deze op pause gezet. 
    if (song1.isPlaying())
  {
      song1.pause();
  } else if (song3.isPlaying())
  {
    song3.pause();
  }
  
  song.play();
  
  
  //als er een beat gevonden word veranderd de vorm 
    if(beat.isOnset() ){
    eRadius = 80; 
    strokeWeight(25);
    }
    
   //bepaalde de opacity van de vorm 
  float a = map(eRadius, 10, 80, 60, 255);
  stroke(60, 255, 0, a);

  //als eRadius kleiner word, veranderd de opacity van de vorm
   eRadius *= 0.95;
   if ( eRadius < 20 ) eRadius = 10;

   
  //aanmaken van de lijnen die loopen in bepaalde vorm 
   for (int i = 0; i < NUM_LINES; i++) {
   line(width/2 +x1(t + i),height/2 + y1(t + i), width/2 + x2(t + i ),height/2 + y2(t + i ));
   }
   
   t += 0.20;
  
}




//tweede liedje met daarbij bijhorende vorm.
void nummer2() {
  
  float h = 10;
  
 //als een ander liedje aan het spelen is word deze op pause gezet. 
    if (song.isPlaying())
  {
      song.pause();
  } else if (song3.isPlaying())
  {
    song3.pause();
  }
  
  
  beat1.detect(song1.mix);
  song1.play();
 
  
  background(0);
  image(arrowRight, 550, 220);
  image(arrowLeft, 30, 220);
  
 //Loop om lijnen aan te maken met random kleur binnen bepaalde kleurcode.
  for (int x=40; x <= width-220; x +=15){
      noStroke();
      strokeWeight(10);
      stroke(244, random(80,150), 66);
      h = random(10, 50);
     
     //als de beat is gedetecteerd zullen de lijnen random langer worden tussen 80 en 150.
      if(beat1.isOnset() ){
        h = random(80, 150);
      } 


      line(x+70, height/2-h, x+70, height/2+h);
    }
    
      

}


//derde liedje met daarbij bijbehorende vorm.
void nummer3(){ 
 
 //als een ander liedje aan het spelen is word deze op pause gezet. 
    if (song1.isPlaying())
  {
      song1.pause();
  } else if (song.isPlaying())
  {
    song.pause();
  }
 
     if (song.isPlaying())
  {
      song.pause();
  }
  
  image(foto, 20, 15);
  beat3.detect(song3.mix);
  
  song3.play();
  
  //als beat gevonden is verander kleur van image
  if (beat3.isOnset()){
    eRadius = 80; 
    tint(161, 33, 36); // rode kleur
  }
  
     eRadius *= 0.95;
   if ( eRadius < 20 ) eRadius = 20;
   
  
  if (eRadius < 50 ){
     tint(255,255,255); // witte kleur
  }
  
}


//mute / pause de muziek 
void muteSong()
{
  
  mutedSong = true;
  
  if (song.isPlaying())
  {
    song.mute();
  }
  
    if (song1.isPlaying())
  {
    song1.mute();
  } 
  
    if (song3.isPlaying())
  {
    song3.mute();
  } 
}


void unmuteSong(){
  
    mutedSong = false;
  
  if (song.isMuted())
  {
    song.unmute();
  }
  
    if (song1.isMuted())
  {
    song1.unmute();
  }
  
    if (song3.isMuted())
  {
    song3.unmute();
  }
}





//________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________




// hand events voor de kinect

void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
}

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events voor de kinect

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  
  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);
  
  //gestureType 0 = zwaaien. 
  if (gestureType == 0) {
        
    //als het liedje al gemute is zal bij zwaaien het liedje geunmute worden, als hij nog niet gemute is zal het liedje gemute worden. 
        if (mutedSong)
        {
          unmuteSong();
        } else if (!mutedSong)
          {
            muteSong();
          }
       
    }
    
    
    //gesture type 1 = klik beweging. als de hand op de clicknext positie de klik beweging maakt komt het volgende liedje. 
      if (gestureType == 1 && clickNext) {
        randomSong++;
        
        if(randomSong > 3){
          randomSong = 1;
        }
    }
    
    
    //als de hand op de clickPrev positie staat en de klik beweging maakt komt het vorige liedje. 
       if (gestureType == 1 && clickPrev) {
        randomSong--;
        
        if(randomSong < 1){
          randomSong = 3;
        }
    }
    
}
