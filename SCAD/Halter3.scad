



difference(){
    difference(){
    difference(){
         union(){
            cube([13, 10, 8]);
            translate([0, 10/2, 8]){
                rotate([0, 90, 0]){
                cylinder(h = 13, r1=10/2, r2 =10/2, $fn=200);     
                }
            }    
        }
            
        translate([3.25, -1, 4]){
            cube([6.5, 17, 15]);
            }    
        }
        translate([-1, 10/2, (13+5)/2]){
            rotate([0, 90, 0]){
                cylinder(h = 17, r1=4/2, r2 =4/2, $fn=200); 
            }
        }
    }
    translate([13/2, 10/2 , -1]){
        cylinder(h = 6, r1=4/2, r2 =5/2, $fn=200);
        
    }  
    translate([13/2, 10/2 , 2.5]){
        cylinder(h = 2, r1=6.5/2, r2 =6.5/2, $fn=200);
    }
}