dist_hole_edge = 6.12;
dist_additional = 2.0;

//@ToDo: Rename hole -> pin or so
hole_diameter = 1;
hole_height = 2.1;

pin_height = 0.5;
slit_size_x = 5;
slit_size_y = 0.3;

plate_height = 0.75;
motor_diameter=7;

smd_led_size_x = 2.0;
smd_led_size_y = 3;
smd_offset_x = 5.25;

side_reinforcement_width = 1.0;

motor_clamp_thickness = 0.7;
motor_clamp_height = 6.0;

width = 4.5;

cylinder(r=hole_diameter/2,h=hole_height,$fn=16);

// Clip is to filigrane, doesnt print well
//{
//  difference(){
//    translate([0,0,hole_height])  cylinder(r1=(hole_diameter/2)*1.00, r2=(hole_diameter/2)*1.65,h=pin_height,$fn=16);
//    translate([0,0,hole_height+pin_height])  cube([slit_size_x, slit_size_y, pin_height*2], center = true);
//  }
//}

// Side reinforcement left
intersection(){
  translate([smd_offset_x,width/2+side_reinforcement_width,0]) rotate([90,0,0]) cylinder(r=smd_led_size_x,h=side_reinforcement_width,$fn=16);
  cube([10.0, 10.0, 10.0]);
}

// Side reinforcement right
intersection(){
  translate([smd_offset_x,-width/2+0*side_reinforcement_width,0]) rotate([90,0,0]) cylinder(r=smd_led_size_x,h=side_reinforcement_width,$fn=16);
  translate([0,-10.0,0]) cube([10.0, 10.0, 10.0]);
}

// Base plate and removed smd led rectangle
{
  difference(){
    translate([-width/2,-width/2]) cube([width/2+ dist_hole_edge + dist_additional + motor_clamp_thickness,width,plate_height]);
    translate([smd_offset_x-smd_led_size_x/2,-smd_led_size_y/2,-0.5]) cube([smd_led_size_x,smd_led_size_y,10.0]);
  }
}


translate([dist_hole_edge + dist_additional +motor_diameter/2+motor_clamp_thickness ,0])
difference(){  
  difference(){
    cylinder(r=motor_diameter/2+motor_clamp_thickness,h=motor_clamp_height,$fn=32);
    translate([0,0,-0.1]) cylinder(r=motor_diameter/2,h=motor_clamp_height*1.5,$fn=32);
  }
  //translate(0, 10, 0) cube(20, 200, 20);
  translate([1.75,-motor_diameter*2,-motor_diameter*2]) cube(motor_diameter*4, motor_diameter*4, motor_diameter*4);

}