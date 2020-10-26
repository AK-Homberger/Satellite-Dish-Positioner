difference() {
    
    cylinder(h = 25, r1=15, r2 =15, $fn=200);
    
    translate ([0, 0, -1]){
    cylinder(h = 20, r1=17.7/2, r2 =17.7/2, $fn=200);
    }
    
}

translate ([7.3, -7, 0]){
cube ([6, 14, 20]);
}

translate ([-7.3-6, -7, 0]){
cube ([6, 14, 20]);
}

difference(){

    union(){
        translate([-15, 0, 32]){
            rotate([0, 90, 0]){
                cylinder(h = 10, r1=15, r2=15, $fn=200);
            }
        }

        translate([5, 0, 32]){
            rotate([0, 90, 0]){
                cylinder(h = 10, r1=15, r2=15, $fn=200);
            }
        }
    }
    
    translate([-16, 0, 36]){
        rotate([0,90, 0]){
            cylinder(h = 32, r1=7.5/2, r2 =7.5/2, $fn=200);
        }
    }
}


translate([-7.5, 10, 15]){
    rotate([-90, 0, 0]){
        difference(){
            difference(){
                 union(){
                    cube([15, 15, 7]);
                    translate([0, 15/2, 7.5]){
                        rotate([0, 90, 0]){
                        cylinder(h = 15, r1=15/2, r2 =15/2, $fn=200);     
                        }
                    }    
                }
                    
                translate([3.25, -1, 4]){
                    cube([8.5, 17, 15]);
                    }    
                }
                translate([-1, 15/2, (15+7.5)/2]){
                    rotate([0, 90, 0]){
                        cylinder(h = 17, r1=4/2, r2 =4/2, $fn=200); 
                    }
                }
            
        }
    }
}