$fn=100; // Controls the smoothness, set to some high number (e.g. 300 to make very smooth)

// Parameters
inner_radius = 8.5;   // Radius of the torus
side_length = 2;     // Length of the square cross-section side
bevel = 0.75;           // Amount of bevel on the square's edges
spoke_thickness = 1; // Thickness of each spoke
//spoke_length = inner_radius; // Length of each spoke
num_spokes = 3;      // Number of spokes (configurable)

mount_offset = 6;
mid_part_radius=3;
mount_hole_radius=1.06/2;
mount_hole_padding=0.5;

screw_hole_offset_from_bottom=1.52;
screw_hole_radius=0.26;
screw_head_radius=0.45;
nut_radius=0.49;

cut_out_triangle = true;

// Module to create a beveled square profile
module beveled_square(size, bevel) {
    offset(r=bevel) offset(delta=-bevel) square([size, size], center=true);
}

// Module for the torus (steering wheel)
module torus(inner_radius, side_length, bevel) {
    rotate_extrude(angle=360)
        translate([inner_radius, 0, 0])
            beveled_square(side_length, bevel);
}

// Module to create a spoke
module spoke(spoke_length, thickness) {
    translate([0, 0, 0])
        rotate([90,0,0])
        cylinder(h=spoke_length, r=thickness, center=true);
        //cube([thickness, spoke_length, thickness], center=true);
}

// Create the steering wheel with spokes
module steering_wheel() {
    // Torus representing the wheel
    torus(inner_radius, side_length, bevel);
    
    spoke_angle = atan(mount_offset/inner_radius);
    spoke_length = sqrt( pow(mount_offset,2) + pow(inner_radius,2));
    
    translate([0, 0, mount_offset])
    
    // Spokes pointing to the center
    for (i = [0:num_spokes-1]) {
        rotate([spoke_angle, 0, i * 360 / num_spokes]) // Evenly space the spokes
            translate([0, -(spoke_length / 2), 0])
                spoke(spoke_length, spoke_thickness);
    }
    
    mid_cyl_height = (spoke_thickness) + (mid_part_radius*tan(spoke_angle));
    //echo (mid_cyl_height)
    
    translate([0, 0, mount_offset-mid_cyl_height])
    cylinder(h=mid_cyl_height, r=mid_part_radius, center=false);
    
    translate([0, 0, mount_offset])
    cylinder(h=mid_part_radius, r1=mid_part_radius, r2=(mount_hole_radius+mount_hole_padding), center=false);
}

module hex_cutout(radius, height) {
    sides = 6;  // Number of sides for the hexagon
    points = [for (i = [0:sides-1]) [radius * cos(i * 360/sides), radius * sin(i * 360/sides)]];

    linear_extrude(height) {
        polygon(points);
    }
}

module triangle(){
// Define edge length
edge_length = 0.6;

// Calculate the height of the equilateral triangle
height = (sqrt(3) / 2) * edge_length;

translate ([-edge_length/2, -height/2, 0])
linear_extrude(height = mount_offset+10) {
    polygon(points=[
        [0, 0], 
        [edge_length, 0], 
        [edge_length / 2, height]
    ]);
}
    
}

module cutouts() {
    translate([0, 0, mount_offset-mid_part_radius/2])
    //translate([0, 0, mount_offset])
    cylinder(h=mid_part_radius*2, r=mount_hole_radius, center=false);
    
    translate([0, 0, mount_offset+mid_part_radius-screw_hole_offset_from_bottom])
    rotate([90,0,90])
    {
      cylinder(h=inner_radius*2, r=screw_hole_radius, center=true);
      
      translate([0,0, mount_hole_radius+mount_hole_padding])
      hex_cutout(nut_radius, 10);  
      
      rotate([180,0,0])  
      translate([0,0, mount_hole_radius+mount_hole_padding])
      cylinder(h=inner_radius*2, r=screw_head_radius, center=false);
      //cylinder(h=inner_radius, r=2*screw_hole_radius, center=true);    
    }
    
    if (cut_out_triangle)
    {
      translate([0, 0, mount_offset-0.2])
      rotate([180,0,0])
      triangle();
    }
}

// Call the steering wheel module
//intersection(){
//triangle();
difference(){
steering_wheel();
cutouts();
}

//translate([0, 0, mount_offset+mid_part_radius-screw_hole_offset_from_bottom])
// cube([6, 2, 2], center=true);

//}