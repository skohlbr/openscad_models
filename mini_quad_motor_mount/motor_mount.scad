// This work uses the  Creative Commons Attribution-Noncommercial-Share Alike license
// https://creativecommons.org/licenses/by-nc-sa/1.0/ © 2016, Stefan Kohlbrecher.


// Distance between the mounting pin an the edge of the frame
dist_hole_edge = 6.12;

//Additional distance beyond the edge of the frame for the clamp
dist_additional = 2.0;

//@ToDo: Rename hole -> pin or so
hole_diameter = 1;
hole_height = 2.1;

pin_height = 0.5;
slit_size_x = 5;
slit_size_y = 0.3;

plate_height = 0.75;
motor_diameter=5.9;

smd_led_size_x = 2.0;
smd_led_size_y = 3;
smd_offset_x = 5.25;

side_reinforcement_width = 1.0;

motor_clamp_thickness = 0.7;
motor_clamp_height = 6.0;
motor_clamp_top_reinforcement_width = 1;

// 0 makes motor clamp half circle, values up to 1 make it go further
motor_clamp_cutoff_factor = 0.6;

width = 4.5;


// Base plate with removed smd led rectangle
module BasePlate(){
  difference(){
    translate([-width/2,-width/2]) cube([width/2+ dist_hole_edge + dist_additional + motor_clamp_thickness,width,plate_height]);
    translate([smd_offset_x-smd_led_size_x/2,-smd_led_size_y/2,-0.5]) cube([smd_led_size_x,smd_led_size_y,10.0]);
  }
}

// Side reinforcement. Half circle to strengthen sides around SMD LED hole
module SideReinforcement(){
  intersection(){
    rotate([90,0,0]) cylinder(r=smd_led_size_x,h=side_reinforcement_width,$fn=16);
    translate([0,0,smd_led_size_x]) cube([smd_led_size_x*2, smd_led_size_x*2, smd_led_size_x*2], center = true);
  }
}

module FrameHolePin()
{
  cylinder(r=hole_diameter/2,h=hole_height,$fn=16);
}

// Clip is too filigrane, doesnt print well. Keeping it for anyone interested to try
module FrameHolePinTopClip()
{
  difference(){
    translate([0,0,hole_height])  cylinder(r1=(hole_diameter/2)*1.00, r2=(hole_diameter/2)*1.65,h=pin_height,$fn=16);
    translate([0,0,hole_height+pin_height])  cube([slit_size_x, slit_size_y, pin_height*2], center = true);
  }
}

module ClampSideReinforcement()
{
  a = [[dist_hole_edge,width/2],
        [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,0],
        [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,motor_diameter/2+motor_clamp_thickness]]; 



  translate([0,0,plate_height/2])
  linear_extrude(height = plate_height, center = true, convexity = 0, twist = 0)
  polygon(a);

  //linear_extrude(height = 10, center = true, convexity = 10, twist = 0)
  //circle();
//cube ([1, 1, 1]);
}

module ClampTopReinforcement()
{
  //clamp_top_poly= [[dist_hole_edge,clamp_top_poly_width],
  //      [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,0],
  //      [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,motor_diameter/2+motor_clamp_thickness]];

  scale_x = (dist_hole_edge + dist_additional) - (smd_offset_x+smd_led_size_x/2);
  scale_y = motor_clamp_height - plate_height;
  

  translate([smd_offset_x+smd_led_size_x/2,-motor_clamp_top_reinforcement_width/2,plate_height+scale_y-0.001])
  rotate([-90,0,0])
  scale([scale_x,scale_y,1])

  {
    difference()
    {
      cube([1, 1, 1]);
      translate([0,0,-motor_clamp_top_reinforcement_width/2]) cylinder(r=1, h=motor_clamp_top_reinforcement_width*2,$fn=32);
    }
    translate([1,0,0])
    cube ([1,1,1]); 
  }
}

//Collects all basic geometry To make it easy to cut out the motor hole and clamp cutoff at the end
module BasicGeom()
{
   FrameHolePin();
   //FrameHolePinTopClip();
   
union(){
   BasePlate();
    //Add side reinforcement at LED hole
    translate([smd_offset_x,width/2+side_reinforcement_width-0.01,0]) SideReinforcement();
    translate([smd_offset_x,-width/2+0.01,0]) SideReinforcement();
}

    translate([dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness ,0])
    cylinder(r=motor_diameter/2+motor_clamp_thickness,h=motor_clamp_height,$fn=32);

    ClampSideReinforcement();
    scale([1,-1,1]) ClampSideReinforcement();

    ClampTopReinforcement();
}


difference(){
  BasicGeom();

  translate([dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness ,0])
  union(){
    translate([0,0,-0.15]) cylinder(r=motor_diameter/2,h=motor_clamp_height*1.5,$fn=32);
    translate([(motor_diameter/2)*motor_clamp_cutoff_factor,-motor_diameter*2,-motor_diameter*2]) cube(motor_diameter*4, motor_diameter*4, motor_diameter*4);
  }
}
