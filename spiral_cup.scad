/********************************************************
 * Parametric Spiral Cup 06/25/2019 - vsergeev
 * https://github.com/vsergeev/3d-spiral-cup
 * CC-BY-4.0
 ********************************************************/

/* [Basic] */

// in mm
height = 100;

// in mm
diameter = 60;

resolution = 50; // [30:Draft 30, 50:Normal 50, 70:Smooth 70]

/* [Spiral] */

spiral_count = 15; // [4:32]

// in mm
spiral_diameter = 10;

// from 0 to 1
spiral_eccentricity = 0.5; // [0:0.1:0.9]

// in degrees
spiral_twist = 90; // [0:10:360]

/* [Custom] */

// in mm
base_height = 5;

// in degrees
taper_twist = 12.5; // [0:0.5:30]

/* [Hidden] */

$fn = resolution;

spiral_height = height - base_height;
taper_height = base_height;

spiral_position = (diameter - spiral_diameter * (1 - spiral_eccentricity)) / 2;

module spiral(index) {
    spiral_phase = (360 / spiral_count) * index;

    translate([0, 0, base_height])
    linear_extrude(height = spiral_height, center = false, twist = spiral_twist)
        rotate([0, 0, spiral_phase])
        translate([spiral_position, 0, 0])
        scale([1 - spiral_eccentricity, 1])
        circle(d = spiral_diameter);
}

module taper(index) {
    /* Phase of spiral at z = spiral_height - taper_height */
    taper_phase = (360 / spiral_count) * index - (1 - (taper_height / spiral_height)) * spiral_twist;

    /* Generate one vertical (twist=0) cylinder and one twisted cylinder (twist=taper_twist) */
    for (twist = [0, taper_twist]) {
        translate([0, 0, base_height + spiral_height - taper_height])
        linear_extrude(height = taper_height, center = false, twist = twist)
            rotate([0, 0, taper_phase])
            translate([spiral_position, 0, 0])
            scale([1 - spiral_eccentricity, 1])
            circle(d = spiral_diameter);
    }
}

module cup() {
    union() {
        /* Base */
        cylinder(d = diameter, h = base_height);

        /* Spirals */
        for (i = [0:spiral_count - 1])
            spiral(i);

        /* Spiral Tapers */
        for (i = [0:spiral_count - 1]) {
            if ($preview && resolution < 70)
                union() taper(i);
            else
                hull() taper(i);
        }
    }
}

cup();
