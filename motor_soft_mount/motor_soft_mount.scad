
// Height of the main plate
plate_thickness = 1.0;


// Motor screw hole diameter
motor_mount_screw_diameter = 1.5;

// Thickness of material around each motor screw hole
motor_mount_screw_padding = 2.0;

// Distance of motor screw holes from center
motor_mount_screw_dist_from_center = 10.0;

// Number of motor screw holes
num_screw_holes = 4;

angle_step = (360/num_screw_holes);

motor_mount_middle_hole_diameter = 5.0;










module ScrewHole()
{
  difference(){
    cylinder(r=motor_mount_screw_diameter+motor_mount_screw_padding,h=plate_thickness,$fn=32, center = true);
    cylinder(r=motor_mount_screw_diameter,h=plate_thickness*2,$fn=32, center = true);
  }       
}


module MiddleHole()
{
  difference(){
    cylinder(r=motor_mount_screw_dist_from_center,h=plate_thickness,$fn=32, center = true);
    cylinder(r=motor_mount_middle_hole_diameter,h=plate_thickness*2,$fn=32, center = true);
  }       
}


module MotorSoftMount()
{
  translate([0,0,plate_thickness/2])
  {  
    MiddleHole();
    
    for (i=[0:num_screw_holes])
    {
      
     rotate([0, 0, i * angle_step])
      
     translate([10,0,0])
     ScrewHole();
     
    }
  }
}

difference(){
  MotorSoftMount();
  //ArmKnotNotch();
}
