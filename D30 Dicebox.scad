// Position the lid based on the variable (1 over the top, 2 on the side)
lid_position = 2;  // Change to 1 or 2 to position the lid

// Dice dimensions
d30_size = 30;
d24_size = 26;

// Tray dimensions
box_wall_thickness = 10;
tray_height = d30_size;
tray_base_thickness = 5;
outer_ring_thickness = 4; // Thickness of the outer ring
track_width = d24_size; // Width of the dice track (set this to the value of the widest die)
dice_length = 240; //Measured length of dice.
dice_circumference = dice_length * .7; // Circumference of the dice track (enter value directly in mm)
inner_ring_height_reduction = 10; // Amount to lower the height of the inner ring

// Calculate the tray dimensions based on the dice circumference
d30_space_radius = d30_size / 2;
dice_track_inner_radius = dice_circumference / (2 * PI);
dice_track_outer_radius = dice_track_inner_radius + track_width;
d30_ring_thickness = dice_track_inner_radius - d30_space_radius; // Dynamic calculation of D30 ring thickness
d30_ring_outer_radius = d30_space_radius + d30_ring_thickness;
outer_ring_outer_radius = dice_track_outer_radius + outer_ring_thickness;
tray_outer_radius = outer_ring_outer_radius + box_wall_thickness;
tray_width = tray_outer_radius * 2;

// Lid dimensions
lid_lip_depth = 6; // Depth of the lid lip
lid_height = 3; // Height of the lid above the lip
lid_wall_thickness = 12;

// Magnet dimensions
magnet_diameter = 5.4;
magnet_height = 3;

// Peg dimensions
peg_diameter = 6; // Slightly reduced peg diameter for better fit
peg_height = 2;

// Peg hole dimensions
peg_hole_diameter = peg_diameter+.6; // Slightly larger than peg diameter for easier fit
peg_hole_height = peg_height+.6; // Slightly larger than peg diameter for easier fit

// Magnet and peg hole offset from the outer edge
hole_offset = 4;

// Angles for magnet and peg holes
magnet_angle = 0;
peg_angle = 60;

// Import the STL file
module import_stl() {
    mirror([0,1,0]) {
			import("LichDCCLogoA.svg_2mm.stl", convexity=10);
		}
}

// Magnet hole positions in the box walls
module box_magnet_holes(hole_height) {
  for (i = [0:2]) {
    rotate([0,0,i*(360/3)+magnet_angle]) translate([tray_outer_radius-box_wall_thickness+hole_offset,0,hole_height]) cylinder(h=magnet_height, r=magnet_diameter/2, $fn=30);
  }
}

// Peg and magnet hole radial position calculation
hole_radial_position = tray_outer_radius - box_wall_thickness + hole_offset;

// Peg hole positions in the box walls
module box_peg_holes(hole_height) {
  for (i = [0:2]) {
    rotate([0,0,i*(360/3)+peg_angle]) translate([hole_radial_position,0,hole_height]) cylinder(h=peg_hole_height, r=peg_hole_diameter/2, $fn=30);
  }
}

// Magnet holes in the lid based on box positions
module lid_magnet_holes() {
  translate([0,0,lid_lip_depth-magnet_height/2]) box_magnet_holes(magnet_height);
}

// Pegs on the lid
module lid_pegs() {
  for (i = [0:2]) {
    rotate([0,0,i*(360/3)+peg_angle]) translate([hole_radial_position,0,lid_height]) cylinder(h=peg_height, r=peg_diameter/2, $fn=30);
  }
}

// Lid base
module lid_base() {
  difference() {
    // Define the outer shape of the lid with hexagonal geometry
    cylinder(h=lid_lip_depth + lid_height, r=tray_outer_radius, $fn=6); // Hexagonal shape
    // Subtract a smaller cylinder for the inner lid space
    translate([0, 0, lid_lip_depth])
    cylinder(h=lid_height + 1, r=tray_outer_radius - lid_wall_thickness, $fn=6); // Maintaining hexagonal shape
    // Include magnet holes
    lid_magnet_holes();
      }
  }


// D30 space
module d30_space() {
  cylinder(h=tray_height-tray_base_thickness+1, r=d30_space_radius, $fn=60);
}

// Dice track
module dice_track() {
  difference() {
    cylinder(h=tray_height-tray_base_thickness+1, r=dice_track_outer_radius, $fn=120);
    cylinder(h=tray_height-tray_base_thickness+1, r=dice_track_inner_radius, $fn=120);
  }
}

// Tray
module dice_tray() {
  difference() {
    // Solid hexagonal prism
    cylinder(h=tray_height, r=tray_outer_radius, $fn=6);
    
    // Subtract the dice track
    translate([0,0,tray_base_thickness]) dice_track();
    
    // Subtract the D30 space
    translate([0,0,tray_base_thickness]) d30_space();
    
    // Lower the height of the inner ring
    translate([0,0,tray_height-inner_ring_height_reduction]) cylinder(h=inner_ring_height_reduction+1, r=dice_track_inner_radius, $fn=120);
    
    // Magnet and peg holes
    box_magnet_holes(tray_height-magnet_height/2);
    box_peg_holes(tray_height-peg_hole_height);
  }
}

// Tray lid
module tray_lid() {
  lid_base();
  translate([0,0,lid_lip_depth]) lid_pegs();
}

module combined_lid() {
    difference() {  // Use difference() if you want the logo to be recessed
        tray_lid();  // Call your lid module
        scale([0.7, 0.7, 0.7])  // Adjust scale if your logo is too big or too small
        translate([-50, 50, 0])  // Adjust these coordinates so that the logo sits correctly on the lid
        import_stl();  // Call your logo module
    }
}

if (lid_position == 1) {
    translate([0,0,tray_height]) combined_lid();  // Position over the top
} else if (lid_position == 2) {
    translate([tray_width+20,0,0]) combined_lid();  // Position on the side
}

// Render the complete model
dice_tray();