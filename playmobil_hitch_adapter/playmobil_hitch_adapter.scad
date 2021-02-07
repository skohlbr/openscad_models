hitch_ring_inner_dia = 4.0;
hitch_ring_outer_dia = 9.0;

ring_strength = (hitch_ring_outer_dia - hitch_ring_inner_dia)/2;
ring_diameter = (hitch_ring_outer_dia + hitch_ring_inner_dia)/2;

height = 5.5;
height_factor = height/ring_strength;
echo (height_factor);

length = 50;
rod_length = length - ring_diameter;

pin_length = 8;
pin_diameter = 4;

module profilePoly()
{    
  circle(d=ring_strength, $fn=50);       
}

module pinGeomSimpleCylinderWithHat()
{
  cylinder(h = height, r1 = ring_diameter/2, r2 = ring_diameter/2, center = true);
  translate([0, 0, height/2+pin_length/2])
  cylinder(h = pin_length, r1 = pin_diameter/2, r2 = pin_diameter/2, center = true, $fn=50);
  translate([0, 0, height/2+(pin_length*15)/16])  
  cylinder(h = pin_length/8, r1 = (pin_diameter)/2, r2 = (pin_diameter*2)/2, center = true, $fn=50);  
}

module pinGeomVaseCylinder()
{
  cylinder(h = height, r1 = ring_diameter/2, r2 = ring_diameter/2, center = true);
  translate([0, 0, height/2+pin_length/2])
  {
    difference()
    {
      cylinder(h = pin_length, r1 = pin_diameter/2, r2 = pin_diameter/2,   center = true, $fn=50);
      scale([1,1,pin_length])
      rotate_extrude(convexity = 10, $fn = 100)
      { 
            translate([pin_diameter/2, 0, 0]) scale([2, 1, 1]) rotate([0, 0, -90]) circle(d=1, $fn=50);
      }   
    }
  }
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

module adapterParts()
{
    scale([1, 1, height_factor*1.1])
    {
      profileAngular(ring_diameter/2, 360);
      translate([ring_diameter/2+rod_length/2,0,0])
      scale([1, 2, 1])  
      profileLinear(rod_length);
      
      translate([rod_length+ring_diameter,0,0])
      {  
      profileAngular(ring_diameter/2, 360);  

      }    
    }
}

intersection()
{cube([1000,1000,height], center=true); 
    {
adapterParts();
        
        }
}

translate([rod_length+ring_diameter,0,0])
//pinGeomSimpleCylinderWithHat();
pinGeomVaseCylinder();

