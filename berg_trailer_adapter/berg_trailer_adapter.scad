// Trailer Coupling Mount with Locking Fork (Final Clean Version)

// -- Parameters --
// Adjust these values to change the model's dimensions

$fn=128; 

// Overall dimensions
part_height = 15;              // Total height of the first section in mm
extension_length = 30;         // Length of the transition section
end_cube_size = 52;            // Edge length of the end cube

// Profile dimensions
cylinder_diameter = 30;        // Diameter of the circular end
bolt_hole_diameter = 12;       // Diameter of the hole for the bolt

// Fork dimensions
fork_cutout_width = 35;        // The width of the material to remove (Y-axis)
// CORRECTED: Cutout depth must be less than end_cube_size. 40mm leaves a 12mm back wall.
fork_cutout_depth = 45;        
lock_cutout_length = 35;       // The total length of the locking slots
lock_cutout_slot_width = 30;   // The width of the locking cutter
lock_cutout_slot_height = 25;  // The height of the locking cutter
lock_cutout_offset = 00;

// Production Parameters
fillet_radius = 5;             // Radius for internal and external fillets


// -- Modules --

// This module creates the custom-shaped cutter for the locking slots
module locking_cutter(length, width, height) {
    union() {
        translate([-lock_cutout_offset, 0, height/2]) {
            rotate([90, 0, 0]) { cylinder(h = width, d = length, center = true); }
        }
        translate([-lock_cutout_offset, 0, -height/2]) {
            rotate([90, 0, 0]) { cylinder(h = width, d = length, center = true); }
        }
        translate([-lock_cutout_offset, 0, 0]) {
            cube([length, width, height], center = true);
        }
    }
}


// -- Model Generation --
// The model is now a single 'difference' operation for clarity and robustness.

// First, we define all the key positions using the parameters
fork_center_x = extension_length + (cylinder_diameter / 2) + (end_cube_size / 2);
fork_front_face_x = fork_center_x + (end_cube_size / 2);
main_cutter_center_x = fork_front_face_x - (fork_cutout_depth / 2);
fork_back_wall_x = main_cutter_center_x - (fork_cutout_depth / 2);

tine_width = (end_cube_size - fork_cutout_width) / 2;
tine_center_y = (fork_cutout_width / 2) + (tine_width / 2);
locking_cut_center_z = end_cube_size / 4;


difference() {

    // --- 1. The COMPLETE SOLID BODY ---
    // This union creates the entire solid part with all smooth transitions and reinforcements.
    union() {
        
        // a) The main constant-height body
        linear_extrude(height = part_height, center = true) {
            hull() {
                circle(d = cylinder_diameter);
                translate([extension_length, 0]) {
                    square(cylinder_diameter, center = true);
                }
            }
        }
        
        // b) The fork block with an integrated, controlled transition
        hull() {
            // This anchors the start of the hull to the end of the main body
            translate([extension_length, 0, 0]) {
                cube([0.1, cylinder_diameter, part_height], center=true);
            }
            
            // This is the full, solid fork block with rounded outer corners
            translate([fork_center_x, 0, 0]) {
                linear_extrude(height = end_cube_size, center = true) {
                    hull() {
                        for (x = [-1, 1], y = [-1, 1]) {
                            translate([
                                x * (end_cube_size / 2 - fillet_radius),
                                y * (end_cube_size / 2 - fillet_radius)
                            ]) circle(r = fillet_radius);
                        }
                    }
                }
            }
        }        
    }
    
    // --- 2. ALL THE CUTTERS ---
    // These objects are now subtracted from the solid body created above.
    
    // a) The main bolt hole
    cylinder(h = part_height + 2, d = bolt_hole_diameter, center = true);
    
    // b) The main fork slot
    translate([main_cutter_center_x, 0, 0]) {
        cube([fork_cutout_depth, fork_cutout_width, end_cube_size + 2], center = true);
    }
    
    // c) The mirrored locking cutouts
    for (mirror = [1, -1]) {
        translate([
            fork_back_wall_x + (lock_cutout_length / 2),
            tine_center_y * mirror,
            locking_cut_center_z * mirror
        ]) {
            locking_cutter(lock_cutout_length, lock_cutout_slot_width, lock_cutout_slot_height);
        }
    }
}