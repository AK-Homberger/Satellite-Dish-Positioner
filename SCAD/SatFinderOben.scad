
difference(){
    
    union(){
        translate ([-5.5, -12.5, 0]){

        cube ([11, 24.8, 7]);
        }

        translate ([-17.5, -12.5, 7]){

        cube ([34.8, 24.8, 10]);
        }

        translate ([-10, -12.5, -5]){

        cube ([20, 24.8, 5]);
        }


        translate([-5, -12.5, -15]){
            cube ([10, 24.8, 10]);
        }

        translate([-5, -0.1, -15]){
            rotate([0, 90, 0]){
                cylinder(h=10, r1=12.4, r2=12.4, $fn=200);
            }
        }
    }
    translate([-6, 0, -18]){
        rotate([0, 90, 0]){
            cylinder(h=12, r1=7.5/2, r2=7.5/2, $fn=200);
        }
    }
    
}