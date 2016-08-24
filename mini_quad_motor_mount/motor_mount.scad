// This work uses the  Creative Commons Attribution-Noncommercial-Share Alike license
// https://creativecommons.org/licenses/by-nc-sa/1.0/ © 2016, Stefan Kohlbrecher.


// Distance between the mounting pin an the edge of the frame. This is fixed for a given frame.
dist_hole_edge = 6.12;

//Additional distance beyond the edge of the frame for the clamp
dist_additional = 2.0;

// Diameter of the pin for the hole in the frame
pin_diameter = 1;

// Diameter of the pin for the hole in the frame
pin_length = 1.35;

// Height of the main plate
plate_thickness = 0.75;

// Width of main plate
plate_width = 4.5;

// Motor diameter. It is recommended to make this a little smaller than actual motor diameter (e.g. 5.9 for 6mm motors)
motor_diameter=5.9;

// Thickness of motor clamp
motor_clamp_thickness = 0.7;

// Height of motor clamp
motor_clamp_height = 6.0;

// Width of motor clamp reinforcement strut
motor_clamp_top_reinforcement_width = 1;

// 0 makes motor clamp half circle, values up to 1 make it go further around the motor
motor_clamp_cutoff_factor = 0.6;

// Size of SMD LED hole (x)
smd_led_size_x = 2.0;

// Size of SMD LED hole (y/width)
smd_led_size_y = 3;

// Distance of SMD LED hole wrt pin
smd_led_offset_x = 5.25;

// Width of the reinforcement half circles near SMD LED
smd_led_side_reinforcement_width = 1.0;


// Base plate with removed smd led rectangle
module BasePlate(){

  union(){
    cylinder(r=plate_width/2,h=plate_thickness,$fn=32);
    difference(){
      translate([0,-plate_width/2]) cube([ dist_hole_edge + dist_additional + motor_clamp_thickness,plate_width,plate_thickness]);
      translate([smd_led_offset_x-smd_led_size_x/2,-smd_led_size_y/2,-0.5]) cube([smd_led_size_x,smd_led_size_y,10.0]);
    }
  }
}

// Side reinforcement. Half circle to strengthen sides around SMD LED hole
module SideReinforcement(){
  intersection(){
    rotate([90,0,0]) cylinder(r=smd_led_size_x,h=smd_led_side_reinforcement_width,$fn=16);
    translate([0,0,smd_led_size_x]) cube([smd_led_size_x*2, smd_led_size_x*2, smd_led_size_x*2], center = true);
  }
}

module FrameHolePin()
{
  translate([0,0,plate_thickness]) cylinder(r=pin_diameter/2,h=pin_length,$fn=16);
}

// Clip is too filigrane, doesnt print well. Keeping it for anyone interested to try
module FrameHolePinTopClip()
{
  // Unused. top clip does not print properly
  top_clip_pin_length = 0.5;
  // Unused. top clip does not print properly
  top_clip_slit_size_x = 5;
  // Unused. top clip does not print properly
  top_clip_slit_size_y = 0.3;
  difference(){
    translate([0,0,pin_length])  cylinder(r1=(pin_diameter/2)*1.00, r2=(pin_diameter/2)*1.65,h=top_clip_pin_length,$fn=16);
    translate([0,0,pin_length+top_clip_pin_length])  cube([top_clip_slit_size_x, top_clip_slit_size_y, top_clip_pin_length*2], center = true);
  }
}

module ClampSideReinforcement()
{
  a = [[dist_hole_edge,plate_width/2],
        [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,0],
        [dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness,motor_diameter/2+motor_clamp_thickness]]; 



  translate([0,0,plate_thickness/2])
  linear_extrude(height = plate_thickness, center = true, convexity = 0, twist = 0)
  polygon(a);

}

module ClampTopReinforcement()
{
  scale_x = (dist_hole_edge + dist_additional) - (smd_led_offset_x+smd_led_size_x/2);
  scale_y = motor_clamp_height - plate_thickness;
  

  translate([smd_led_offset_x+smd_led_size_x/2,-motor_clamp_top_reinforcement_width/2,plate_thickness+scale_y-0.001])
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
    translate([smd_led_offset_x,plate_width/2+smd_led_side_reinforcement_width-0.01,0]) SideReinforcement();
    translate([smd_led_offset_x,-plate_width/2+0.01,0]) SideReinforcement();
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
