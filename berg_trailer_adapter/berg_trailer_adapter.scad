// Trailer Coupling Mount with Locking Fork

// -- Parameters --
// Adjust these values to change the model's dimensions

// Overall dimensions
part_height = 15;              // Total height of the first section in mm
extension_length = 20;         // Length of the transition section
end_cube_size = 70;            // Edge length of the end cube

// Profile dimensions
cylinder_diameter = 30;        // Diameter of the circular end
bolt_hole_diameter = 12;       // Diameter of the hole for the bolt

// Fork dimensions
fork_cutout_width = 50;        // The width of the material to remove (Y-axis)
fork_cutout_depth = 70;        // The depth of the cut (X-axis)
lock_cutout_length = 38;       // The total length of the locking slots
lock_cutout_slot_width = 17;   // The width of the locking cutter
lock_cutout_slot_height = 35;  // The height of the locking cutter

// -- Modules --

// New module for the locking cutter cube
module locking_cutter(length, width, height) {
    // The cylinder's height axis is now oriented along the Y-axis.
    union() {
        // Cylinder for the round end
        translate([-height / 4, 0, height/2]) {
            rotate([90, 0, 0]) { // Rotate around X-axis to align cylinder's height with Y-axis
                cylinder(h = width, d = length - height / 2, center = true, $fn = 32);
            }
        }
        // Cylinder for the round end
        translate([-height / 4, 0, -height/2]) {
            rotate([90, 0, 0]) { // Rotate around X-axis to align cylinder's height with Y-axis
                cylinder(h = width, d = length - height / 2, center = true, $fn = 32);
            }
        }
        // Cube for the straight body
        translate([-height / 4, 0, 0]) {
            cube([length - height / 2, width, height], center = true);
        }
    }
}

// Module for creating the entire fork end
module fork_end() {
    // Calculate start position of the locking cuts for clarity
    cut_start_x = extension_length + fork_cutout_depth/2 ; 
    
    difference() {
        // A) The solid 70x70x70 cube that we will cut into
        translate([extension_length + (cylinder_diameter / 2) + (end_cube_size / 2), 0, 0]) {
            cube(end_cube_size, center = true);
        }
        
        // B) The main cutter for the fork slot
        translate([extension_length + (cylinder_diameter / 2) + (end_cube_size / 2) + 10, 0, 0]) {
            cube([fork_cutout_depth, fork_cutout_width, end_cube_size + 2], center = true);
        }
        
        // C) The new locking cutout on the TOP of one tine (+Y side)
        translate([cut_start_x + (lock_cutout_length / 2), 30, 17.5]) {
            locking_cutter(lock_cutout_length, lock_cutout_slot_width, lock_cutout_slot_height);
        }

        // D) The mirrored locking cutout on the BOTTOM of the other tine (-Y side)
        translate([cut_start_x + (lock_cutout_length / 2), -30, -17.5]) {
            locking_cutter(lock_cutout_length, lock_cutout_slot_width, lock_cutout_slot_height);
        }
    }
}


// -- Model Generation --
// The main code that builds the part.

union() {
    
    // Part 1: Original hulled shape with the hole (unchanged)
    difference() {
        linear_extrude(height = part_height, center = true) {
            hull() {
                circle(d = cylinder_diameter);
                translate([extension_length, 0]) {
                    square(cylinder_diameter, center = true);
                }
            }
        }
        cylinder(h = part_height + 2, d = bolt_hole_diameter, center = true);
    }
    
    // Part 2: The fork-shaped end piece, created by the module
    fork_end();
}