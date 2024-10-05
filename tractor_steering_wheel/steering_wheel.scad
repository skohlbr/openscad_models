$fn=30; // Controls the smoothness

// Parameters
inner_radius = 15;   // Radius of the torus
side_length = 4;     // Length of the square cross-section side
bevel = 1.5;           // Amount of bevel on the square's edges
spoke_thickness = 2; // Thickness of each spoke
spoke_length = inner_radius; // Length of each spoke
num_spokes = 3;      // Number of spokes (configurable)

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
    
    // Spokes pointing to the center
    for (i = [0:num_spokes-1]) {
        rotate([0, 0, i * 360 / num_spokes]) // Evenly space the spokes
            translate([0, -(inner_radius / 2), 0])
                spoke(spoke_length, spoke_thickness);
    }
}

// Call the steering wheel module
steering_wheel();