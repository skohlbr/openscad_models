
frame_size = 80.0;

// Height of mount.
plate_thickness = 2.0;

// Motor screw hole diameter
motor_mount_screw_diameter = 1.6;

// Thickness of material around each motor screw hole
motor_mount_screw_padding = 3.0;

// Distance of motor screw holes from center
motor_mount_screw_dist_from_center = 8.5/2;

// Number of motor screw holes
num_screw_holes = 4;

// Diameter of the middle hole, to make room for motor c-clip
motor_mount_middle_hole_diameter =  2.25;

// Padding of middle part defaults to middle of screw holes. Play around with this param to make it thinner of thicker.
motor_mount_middle_hole_padding_modifier = 3.0;

arm_width = 5.0;


angle_step = (360/num_screw_holes);

prop_height = 10.0;
prop_diameter = 75;

fc_mount_format = 16;
fc_screw_dia = 2;




module ScrewHole()
{
  difference(){
    cylinder(r=motor_mount_screw_diameter/2+motor_mount_screw_padding,h=plate_thickness,$fn=32, center = true);
    cylinder(r=motor_mount_screw_diameter/2,h=plate_thickness*2,$fn=32, center = true);
  }       
}


module MiddleHole()
{
  difference(){  
    difference(){
      cylinder(r=motor_mount_screw_dist_from_center+motor_mount_middle_hole_padding_modifier,h=plate_thickness,$fn=32, center = true);
      cylinder(r=motor_mount_middle_hole_diameter,h=plate_thickness*2,$fn=32, center = true);
    }
        
    for (i=[0:num_screw_holes])
    {
      rotate([0, 0, i * angle_step])
      translate([motor_mount_screw_dist_from_center,0,0])
      cylinder(r=motor_mount_screw_diameter/2+motor_mount_screw_padding,h=plate_thickness*2,$fn=32, center = true);
    }

  }    
}


module MotorMount()
{
  translate([0,0,plate_thickness/2])
  {  
    MiddleHole();
    
    difference(){  
      for (i=[0:num_screw_holes])
      {
        rotate([0, 0, i * angle_step])
        translate([motor_mount_screw_dist_from_center,0,0])
        ScrewHole();
     }
     cylinder(r=motor_mount_middle_hole_diameter,h=plate_thickness*2,$fn=32, center = true);
    }
  }
}

module Propeller()
{
  translate ([0, 0, prop_height])
  cylinder  (1.0 ,    prop_diameter/2,    prop_diameter/2);    
}

module AddProps()
{
  translate([ frame_size/2, frame_size/2,0]) Propeller();
  translate([ frame_size/2,-frame_size/2,0]) Propeller();
  translate([-frame_size/2,-frame_size/2,0]) Propeller();
  translate([-frame_size/2, frame_size/2,0]) Propeller();   
}

module FcPin()
{
     cylinder  (5.0 ,    (fc_screw_dia/2)*1.5,    (fc_screw_dia/2)*1.5, $fn=180);
     translate([0,0,5.0])
     cylinder  (4.0 ,        (fc_screw_dia/2),    (fc_screw_dia/2), $fn=180);
}

module FcMount()
{
  translate([ fc_mount_format/2, fc_mount_format/2,2.0]) FcPin();   
  translate([ fc_mount_format/2,-fc_mount_format/2,2.0]) FcPin();
  translate([-fc_mount_format/2,-fc_mount_format/2,2.0]) FcPin();
  translate([-fc_mount_format/2, fc_mount_format/2,2.0]) FcPin();       
}

module simpleDiagonal()
{
  translate([0,0,plate_thickness/2])  
  rotate([0, 0, 45])
  cube([frame_size * sqrt(2) - motor_mount_middle_hole_diameter*2 - motor_mount_middle_hole_padding_modifier*2, arm_width, plate_thickness], center = true);        
}

module simpleCross()
{
  simpleDiagonal();
  rotate([0, 0, 90]) simpleDiagonal();
}

module profilePoly()
{
   rotate([0, 0, 90]) polygon( points=[[-0.5,0],[0.5,0],[1.8,2.5],[1, 3.8], [0,4],[-1, 3.8],[-1.8,2.5]] ); 
}

module profileLinear(length)
{
//translate([0,0,plate_thickness/2]) 
  rotate([0, 90, 0])
  linear_extrude(height = length, center = true, convexity = 10, twist = 0)  profilePoly();
}

module profileAngular(radius, angle)
{
  //rotate([0, 90, 0])
  rotate_extrude(convexity = 10, $fn = 100, angle = angle)
translate([radius, 0, 0])  rotate([0, 0, -90]) profilePoly();
    
}

module angledProfileCross(size)
{
    translate([-size, 0, 0])
    rotate([0, 0, -45])
    profileAngular((size/2) * sqrt(2), 90);
    
    translate([0,-size, 0])
    rotate([0, 0, 45])
    profileAngular((size/2) * sqrt(2), 90);
    
    translate([size, 0,0])
    rotate([0, 0, 135])
    profileAngular((size/2) * sqrt(2), 90);
    
    translate([0,size, 0])
    rotate([0, 0, -135])
    profileAngular((size/2) * sqrt(2), 90);

}

module frameTopSubtractor(size, height)
{
  translate([0, 0, 0])
  rotate_extrude(convexity = 10, $fn = 180)
  //translate([0, 0, 0])  rotate([0, 0, -90])    rotate([0, 0, 90])
  polygon( points=[[10,height],[(size/2) * sqrt(2),height],[(size/2) * sqrt(2),0]] );
}

module profileCross()
{
    union(){
  rotate([0, 0, 45])
  profileLinear(length=frame_size * sqrt(2) - motor_mount_middle_hole_diameter*2 - motor_mount_middle_hole_padding_modifier*2);  
    
      rotate([0, 0, -45])
  profileLinear(length=frame_size * sqrt(2) - motor_mount_middle_hole_diameter*2 - motor_mount_middle_hole_padding_modifier*2);
    }
}

translate([ frame_size/2, frame_size/2,0]) MotorMount();
translate([ frame_size/2,-frame_size/2,0]) MotorMount();
translate([-frame_size/2,-frame_size/2,0]) MotorMount();
translate([-frame_size/2, frame_size/2,0]) MotorMount();

//translate([0, 0, 0])
//rotate_extrude(convexity = 10, $fn = 100)
//translate([0, 0, 0])  rotate([0, 0, -90])    rotate([0, 0, 90])
//polygon( points=[[0,10],[frame_size,10],[frame_size,00]] );

difference(){
    union(){
  angledProfileCross(frame_size-10);
  profileCross();
    }
translate([0,0,plate_thickness])
frameTopSubtractor(frame_size-7, 10);
}

//simpleCross();

//AddProps();
FcMount();


//profileLinear(length=500);



//rotate_extrude($fn=200)
//translate([0, 0, -20])
//rotate([0, 90, 0])
//linear_extrude(height = 10, center = true, convexity = 10, twist = 0) rotate([0, 0, 0]) polygon( points=[[0,0],[2,1],[1,2],[1,3],[3,4],[0,5]] );
//linear_extrude(height = frame_size, center = true, convexity = 10, twist = 0) rotate([0, 0, 90]) polygon( points=[[-0.5,0],[0.5,0],[1.8,2.5],[1, 3.8], [0,4],[-1, 3.8],[-1.8,2.5]] );



//translate([0,0,0])
//   rotate_extrude(angle=90, convexity=10)
//       translate([frame_size/2, 0])
//       difference(){
//           circle(arm_width);
//           translate([0, -arm_width,0]) square(arm_width*2, center = true);
//           //circle(arm_width/2);
//       }
