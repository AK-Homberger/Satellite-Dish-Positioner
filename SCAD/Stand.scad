h = 85;
b = 100;
w = 22;
d = 4;
r = 7.8 /2;
bh = 75;
s = b + 70;

difference(){
    union(){
        cube([d, w, h]);
        translate([b+d, 0, 0]){
            cube([d, w, h]);
        }
        translate([((b-s)/2), 0 ,0]){
            cube([s+(2*d), w, d]);
        }
    }
    translate([-1, w/2, bh]){
            rotate([0, 90, 0]){
            cylinder(h=b+(2*d)+2, r1=r, r2=r, $fn=200);
        }
    }   
}