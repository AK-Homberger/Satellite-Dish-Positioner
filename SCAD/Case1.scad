/*!
@brief Generic Electronic Device packaging for Tyndall
@details This OpenSCAD script will generate a 2 part fit together packaging.
This starts by making a pair of hollow rounded cuboids by differencing a slightly smaller one from a slightly larger one
then it will also remove another small amount of material to make a lip
one of the objects will have an internal lip the other one will have an external lip
you will be able to specify fit type
It can also create simple square or cylindrical cutouts on any face of the top or bottom half
4 cylindrical support posts can also be added on the bottom or top half to help position a PCB or similar device
all these features can be controlled from the variables section

@author Mark Gaffney
@version 1.6
@date 2012-05-29

@todo
enable for measurements from corners or centres of faces etc
add "fit factor" for cutouts
add option for connecting struts between top and bottom in side by side mode
re-incorporate some advanced features from v1.5

@warning
@note
Changes from previous versions:

v1.6
 - 	Incorporates improvements from brians physiological health board case v2.6
 - - 	better support for adding parts, changing features and changing layout using control variables
 - - 	Can select how tall the 2 halves are relative to each other
 - - 	Added method to choose whether to have fully cut or covered cutouts
 - -	Added optional mouse-ears
 - 	more logical method for creating circular and square cutouts in preparation for array based system
 - 	simplified method for controlling lip tolerance
 - 	abandoned some features from v1.5 such as profiled lips in quest for simplicity
 - 	method optionally adding posts to top and bottom
 - 	variables for controlling support posts on top and bottom separately
 - 	pasted contents of mouse ears and rounded cuboid as modules rather than accessing them as external files

v1.5
	adjusted a few values after receiving SLA proto-types
	increased height of posts
	added support structures on top side
	decrease diameter of support structures on top side slightly to allow for brackets at end of 40 way
	decreased z clearance
	removed includes/uses needed for WIMU packaging
	
v1.4
	added angled lip (Cube_cone_cylinder_minkowski sum) for better mating of top and bottom parts when made via SLA/SLS etc
	new more simplistic rounded cuboid module
	moved around the cutout for the uUSB so that there wasn't such a thin peice of plastic above it
changed post type to nub as SLA should be able to handle the resolution
	added easier control of orientation of parts relative to each other using single variable side_by_side
	added axis labels to most faces and tyndall logo to bottom
	added new fit type for super accurate manufacturing techniques such as SLA
v1.3
	Fix cutout positions for TOP SQUARE East and BOTTOM SQUARE West side
	Fix position of base of support posts on bottom half
v1.2
	Fixed Inner and Outer Lip Clearance implementation
	Added ability to generate support posts on bottom half of either nub or screw hole type
v1.1
	???This version was lost in a computer crash. GRRRR!
	???It implemented the ability to choose the reference point for measurements for each side
	???Let this be a lesson!
	???Back your stuff up regularly and on separate devices!
v 1.0
	Ensure pcb_clearance and fit clearance is taken into account
	fit type values changed
		force_fit from 0.4 to 0.2
		hold_fit from 0.6 to 0.3
		slide_fit from 0.8 to 0.4
		free_fit from 1to 0.5
	add cylinder & square holes to all faces
	allowed to stack or see side by side
	replace 0.1s with a_bit
	check holes on top & bottom sides meet properly
*/

//*********includes********

//use <mouse_ears_test.scad>;//mouse_ears (total_x, total_y, 2*z_resolution, mouse_ear_diameter);
//use <rounded_cuboid_v2.5.scad>;//rounded_cuboid_2_5(tot_l, tot_b, tot_h, tot_r, tot_s,center=true/false,use_sphere,top_n_bottom); hollow_rounded_cuboid_2_5(tot_l, tot_b, tot_h, tot_r, tot_s, wall_t,center=true/false,use_sphere,top_n_bottom);

//*************Control*Variables****************

has_mouse_ears=0;
has_bottom=1;
has_top=1;
has_posts=0;
posts_on_top=1;
posts_on_bottom=0;
is_side_by_side=1;
has_device=0;// for optionally showing an imported model of the internal device, not used here
device_on_top=0;
//has_switch=0; //for optionally showing an imported part, not used here
//simple_lip=0;//for choosing if a simple (1) or locking type lip (0) is used between the 2 halves, not used yet

//***********Pre*Defined*Variables**************

z_resolution=0.32;//this is how thick your printed layers are
xy_resolution=0.5;//how thick is an extruder filament in XY plane

//clearances for the interlocking lips on 3d printed parts, these values will depend on the printer it is made on. Users should NOT change these
super_fit=0.0;//
force_fit=0.2; //!@param force_fit, this is the separation between surfaces that will give a tight fit
hold_fit=0.3; //this is the separation between surfaces that will give a fit that will hold itself together but be easy to remove
slide_fit=0.4; //this is the separation between surfaces that will give a free moving fit without much wobble
free_fit=0.5; //this is the separation between surfaces that will give a free moving & loose but easy to assemble fit

//fudge
a_bit=0.1; //This is used to move items, oversize or undersize them by small amount to maintain manifoldness of the generated 3d shape, this should be on the order of 10% of the smallest dimension you will plan to use 

//**************User*Variables*****************

//internal dimensions
int_l_holder=90;//max length of the item to be held internally
int_b_holder=52;//max breadth of the item to be held internally
int_h_holder=25;//max height of the item to be held internally
int_r_holder=0.5;//radius of the corners of the device to be held internally
int_tol_holder=1.5;//distance between internal walls and edges of the item to be held internally, this allows for devices that may not be accurately measured or made and should generally be >0.5mm
int_r_tol_holder=0.1;//tolerance for the internal corners
curve_f_holder=3;//how many facets do the curved corners have?
wall_t_holder=3;//how thick are the vertical walls?
base_t_holder=2;//how thick is the base?

//lip dimensions
lip_h=1.5;//how tall are the interlocking lips?
lip_fit=super_fit;//what is the tolerance for the fit between the two sets of interlocking lips?
lip_t= wall_t_holder/2-lip_fit;//automatically calculated lip thickness (width)

//external dimensions
ext_l_holder=int_l_holder+2*(int_tol_holder+wall_t_holder);
ext_b_holder=int_b_holder+2*(int_tol_holder+wall_t_holder);
ext_h_holder=int_h_holder+2*int_tol_holder+2*base_t_holder;
ext_r_holder=int_r_holder+int_r_tol_holder+wall_t_holder;
bottom_top_int_h_ratio=0.22;//how tall is the internal void of the bottom section relative to the top section (0.5 would give 2 halves of equal height)
bottom_h=(int_h_holder*bottom_top_int_h_ratio)+int_tol_holder+base_t_holder+lip_h/2;//how tall is the bottom half
top_h=ext_h_holder-bottom_h+lip_h;//how tall is the top half

//features
mouse_ear_diameter=12;
mouse_ear_thickness=2*z_resolution;
side_side_separation=2;//how far apart the two halves are if generated together


//cutout variables
cutout_wall_thickness=0*xy_resolution; //how thick is the plastic left in the cutouts on the sides? set to 0 if you do not want any plastic left in these cutouts
cutout_base_thickness=2*z_resolution;//how thick is the plastic left in the cutouts on the bottom or top? set to 0 if you do not want any plastic left in these cutouts

north_cutout=1;//if 1 cutout on this side else none
n_cutout_c=1;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
n_cutout_l=10;//length/tallness of the cutout
n_cutout_b=22;//breadth of the cutout
n_cutout_h=wall_t_holder+2*a_bit;//basically wall thickness plus a bit
n_cutout_r=2.5;//radius of the corners of the cutout
n_cutout_e=4;//height of the bottom of the cutout above the bottom of the holder 
n_cutout_t=0;//translation along the face -left +right as you look at the face from outside

south_cutout=0;//if 1 cutout on this side else none
s_cutout_c=0;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
s_cutout_l=8;//length/tallness of the cutout
s_cutout_b=11;//breadth of the cutout
s_cutout_h=wall_t_holder+2*a_bit;//basically wall thickness plus a bit
s_cutout_r=2;//radius of the corners of the cutout
s_cutout_e=s_cutout_l+(-int_h_holder -lip_h)/2-int_tol_holder -1;//height of the bottom of the cutout above the bottom of the holder 
s_cutout_t=-1;//translation along the face -left +right

south_cutout2=0;//if 1 cutout on this side else none
s_cutout_c2=0;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
s_cutout_l2=7;//length/tallness of the cutout
s_cutout_b2=13;//breadth of the cutout
s_cutout_h2=wall_t_holder+2*a_bit;//basically wall thickness plus a bit
s_cutout_r2=1;//radius of the corners of the cutout
s_cutout_e2=0;//height of the bottom of the cutout above the bottom of the holder 
s_cutout_t2=0;//translation along the face -left +right

east_cutout=0;//ECG cutout
e_cutout_c=0;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
e_cutout_l=9;//length/tallness of the cutout
e_cutout_b=13;//breadth of the cutout
e_cutout_h=wall_t_holder+2*a_bit;//basically wall thickness plus a bit
e_cutout_r=3;//radius of the corners of the cutout
e_cutout_e=2;//e_cutout_l+(-int_h_holder -lip_h)/2-int_tol_holder;//height of the bottom of the cutout above the bottom of the holder 
e_cutout_t=0;//(int_l_holder/2)-46.5-4;//translation along the face -left +right

west_cutout=0;//switch cutout
w_cutout_c=1;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
w_cutout_l=10;//length/tallness of the cutout
w_cutout_b=10;//breadth of the cutout
w_cutout_h=wall_t_holder+2*a_bit;//basically wall thickness plus a bit
w_cutout_r=2;//radius of the corners of the cutout
w_cutout_e=5;//w_cutout_l+(-int_h_holder -lip_h)/2-int_tol_holder;//height of the bottom of the cutout above the bottom of the holder 
w_cutout_t=10;//translation along the face -left +right

top_cutout=0;//top cutout
t_cutout_c=1;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
t_cutout_l=25;//length/tallness of the cutout
t_cutout_b=20;//breadth of the cutout
t_cutout_h=base_t_holder+2*a_bit;//basically wall thickness plus a bit
t_cutout_r=7;//radius of the corners of the cutout
t_cutout_x=20;//height of the bottom of the cutout above the bottom of the holder 
t_cutout_y=15;//translation along the face -left +right

bottom_cutout=0;//bottom cutout
b_cutout_c=1;//if 1 gives circle just using the _r value and ignoring the others, else gives rounded square
b_cutout_l=25;//length/tallness of the cutout
b_cutout_b=20;//breadth of the cutout
b_cutout_h=base_t_holder+2*a_bit;//basically wall thickness plus a bit
b_cutout_r=7;//radius of the corners of the cutout
b_cutout_x=20;//position of the cutout
b_cutout_y=15;//position of the cutout


//PCB Support Posts (if enabled, four cylindrical posts will be made with their centres on the corners of a user defined rectangle offset from the centroid by a user controlled amount
//cylindrical_posts (post_l,post_b,post_h_outer,post_r_outer,post_h_inner,post_r_inner,post_x_offset,post_y_offset,post_type)
//bottom
	b_post_outer_r=3;	//external radius of the post
	b_post_inner_r=1;	//radius of the nub (or screw hole)
	b_post_outer_h=4.3;	//height of the post
	b_post_inner_h=1.7;	//height (or depth) of the nub (or screw hole)
	b_post_type=1;	//if 1 gives a nub topped post, if 0 gives a screw hole post
	b_post_x_sep=60;	//X distance between post centres
	b_post_y_sep=40;	//Y distance between post centres
	b_post_x_offset=8;	//X distance between 4 post centroid and bottom face centroid
	b_post_y_offset=5;	//Y distance between 4 post centroid and bottom face centroid
//top
	t_post_outer_r=3;	//external radius of the post
	t_post_inner_r=1;	//radius of the nub (or screw hole)
	t_post_outer_h=6;	//height of the post
	t_post_inner_h=1.7;	//height (or depth) of the nub (or screw hole)
	t_post_type=0;	//if 1 gives a nub topped post, if 0 gives a screw hole post
	t_post_x_sep=60;	//X distance between post centres
	t_post_y_sep=30;	//Y distance between post centres
	t_post_x_offset=10;	//X distance between 4 post centroid and bottom face centroid
	t_post_y_offset=1;	//Y distance between 4 post centroid and bottom face centroid


//*********************Calls*******************

//holder calls
if (has_bottom==1 && has_mouse_ears==1){
	translate(v=[0,is_side_by_side*(ext_b_holder+side_side_separation)/2,0]) mouse_ears (ext_l_holder, ext_b_holder, mouse_ear_thickness, mouse_ear_diameter);
}


if (has_bottom==1){
	translate(v=[0,is_side_by_side*(ext_b_holder+side_side_separation)/2,0]) {

	//	if (has_switch==1){//an accessory model can be loaded here
	//		translate(v=[-18.8,ext_b_holder/2-wall_t_holder-a_bit-8,base_t_holder+0.5]) color("DarkSlateGrey") rotate(a=[90,0,180]) import("2012_05_14-Base_station_switch-v0.2-Brians-v2-6.stl");
	//	}
	
	//	if(has_device==1 && device_on_top==0){//a device resembling the electronics can be inserted here
	//		translate(v=[battery_cable_length-int_l_holder/2,-int_b_holder/2,base_t_holder+int_tol_holder])color([0,1,1,1])phys_health_layer(1, 1, 1, 1);
	//	}
	
		if(has_posts==1 && posts_on_bottom==1){
			translate(v=[0,0,base_t_holder-a_bit]) cylindrical_posts (b_post_x_sep,b_post_y_sep,b_post_outer_h+b_post_inner_h,b_post_outer_r,b_post_inner_h,b_post_inner_r,b_post_x_offset,b_post_y_offset,b_post_type); //cylindrical_posts (post_l,post_b,post_h_outer,post_r_outer,post_h_inner,post_r_inner,post_x_offset,post_y_offset,post_type)
		}

		difference(){//make internal hollow cuboid
			translate(v=[0,0,0]) rounded_cuboid_2_5(ext_l_holder,ext_b_holder,int_h_holder*bottom_top_int_h_ratio+int_tol_holder+base_t_holder+lip_h/2,ext_r_holder,curve_f_holder,true);
			translate(v=[0,0,base_t_holder]) rounded_cuboid_2_5(ext_l_holder-2*wall_t_holder,ext_b_holder-2*wall_t_holder,ext_h_holder,ext_r_holder-wall_t_holder,curve_f_holder,true);
			translate(v=[0,0,int_h_holder*bottom_top_int_h_ratio+int_tol_holder+base_t_holder-lip_h/2]) rounded_cuboid_2_5(ext_l_holder-2*lip_t,ext_b_holder-2*lip_t,ext_h_holder,ext_r_holder-wall_t_holder/2,curve_f_holder,true);//cutout to make the lips
			translate(v=[0,0,ext_h_holder/2]){
				if(north_cutout==1){
					if(n_cutout_c==1){
						#translate(v=[-cutout_wall_thickness+ext_l_holder/2,n_cutout_t,n_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=n_cutout_r,h=n_cutout_h,center=false); //circular cutout on "North" end	
					}else{
						#translate(v=[-cutout_wall_thickness+ext_l_holder/2,n_cutout_t,n_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) rounded_cuboid_2_5 (n_cutout_l,n_cutout_b,n_cutout_h,n_cutout_r,curve_f_holder,center=true); //square cutout on "North" end	
					}
				}if(south_cutout==1){
					if(s_cutout_c==1){
						translate(v=[cutout_wall_thickness-a_bit-ext_l_holder/2,-s_cutout_t,s_cutout_e-int_h_holder/2]) rotate(a=[0,90,0]) cylinder (r=s_cutout_r,h=s_cutout_h,center=false); //circular cutout on "South" end	
					}else{
						#translate(v=[cutout_wall_thickness-a_bit-ext_l_holder/2,-s_cutout_t,s_cutout_e+base_t_holder-s_cutout_l/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (s_cutout_l,s_cutout_b,s_cutout_h,s_cutout_r,curve_f_holder,center=true); //mUSB cutout on "south" end
					}
				}if(south_cutout2==1){
					if(s_cutout_c2==1){
						#	translate(v=[cutout_wall_thickness-a_bit-ext_l_holder/2,-s_cutout_t2,s_cutout_e2-int_h_holder/2]) rotate(a=[0,90,0]) cylinder (r=s_cutout_r2,h=s_cutout_h2,center=false); //circular cutout on "South" end	
					}else{
						translate(v=[cutout_wall_thickness-a_bit-ext_l_holder/2,-s_cutout_t2,s_cutout_e2+base_t_holder-s_cutout_l2/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (s_cutout_l2,s_cutout_b2,s_cutout_h2,s_cutout_r2,curve_f_holder,center=true); //uSD cutout on "south" end
					}
				}if(east_cutout==1){
					if(e_cutout_c==1){
						#rotate(a=[0,0,90]) translate(v=[cutout_wall_thickness-a_bit-ext_b_holder/2,-e_cutout_t,e_cutout_e-int_h_holder/2]) rotate(a=[0,90,0]) cylinder (r=e_cutout_r,h=e_cutout_h,center=false); //circular cutout on "East" end	
					}else{
						rotate(a=[0,0,90])translate(v=[cutout_wall_thickness-a_bit-ext_b_holder/2,-e_cutout_t,e_cutout_e+base_t_holder-e_cutout_l/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (e_cutout_l,e_cutout_b,e_cutout_h,e_cutout_r,curve_f_holder,center=true); //ECG cutout on "East" end
					}
				}if(west_cutout==1){
					if(w_cutout_c==1){
						#rotate(a=[0,0,-90]) translate(v=[cutout_wall_thickness-a_bit-ext_b_holder/2,-w_cutout_t,w_cutout_e-int_h_holder/2]) rotate(a=[0,90,0]) cylinder (r=w_cutout_r,h=w_cutout_h,center=false); //circular cutout on "West" end	
					}else{
						rotate(a=[0,0,-90])translate(v=[cutout_wall_thickness-a_bit-ext_b_holder/2,-w_cutout_t,w_cutout_e+base_t_holder-w_cutout_l/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (w_cutout_l,w_cutout_b,w_cutout_h,w_cutout_r,curve_f_holder,center=true); //switch cutout on "West" end
					}
				}if(bottom_cutout==1){
					if(b_cutout_c==1){
						#translate(v=[b_cutout_x,b_cutout_y,-ext_h_holder/2+cutout_base_thickness]) cylinder (r=b_cutout_r,h=b_cutout_h,center=false); //circular cutout on "Bottom" end	
					}else{
					#	translate(v=[b_cutout_x,b_cutout_y,-ext_h_holder/2+cutout_base_thickness]) rotate(a=[0,0,0])rounded_cuboid_2_5 (b_cutout_l,b_cutout_b,b_cutout_h,b_cutout_r,curve_f_holder,center=true); //switch cutout on "Bottom" end
					}
				}
			}
		}
	}
}

if (has_top==1){
	rotate(a=[0,(is_side_by_side-1)*180,(is_side_by_side-1)*180]) translate(v=[0,-is_side_by_side*(ext_b_holder+side_side_separation)/2,-(abs(is_side_by_side-1))*ext_h_holder  +(abs(has_top-1))*ext_h_holder ]){

	if(has_device==1 && device_on_top==1){	translate(v=[battery_cable_length-int_l_holder/2,int_b_holder/2,cube_height_top+int_tol_holder+a_bit])color([0,1,1,1])rotate(a=[180,0,]) phys_health_layer(1, 1, 1, 1);
	}

		if (has_mouse_ears==1 && is_side_by_side==1){
			mouse_ears (ext_l_holder, ext_b_holder, mouse_ear_thickness, mouse_ear_diameter);
		}

		if(has_posts==1 && posts_on_top==1){
			translate(v=[0,0,base_t_holder-a_bit]) cylindrical_posts (t_post_x_sep,t_post_y_sep,t_post_outer_h+t_post_inner_h,t_post_outer_r,t_post_inner_h,t_post_inner_r,t_post_x_offset,t_post_y_offset,t_post_type); //cylindrical_posts (post_l,post_b,post_h_outer,post_r_outer,post_h_inner,post_r_inner,post_x_offset,post_y_offset,post_type)
		}


		difference(){//make internal hollow cuboid
			translate(v=[0,0,0]) rounded_cuboid_2_5(ext_l_holder,ext_b_holder,top_h,ext_r_holder,curve_f_holder,true);
			translate(v=[0,0,base_t_holder]) rounded_cuboid_2_5(ext_l_holder-2*wall_t_holder,ext_b_holder-2*wall_t_holder,ext_h_holder,ext_r_holder-wall_t_holder,curve_f_holder,true);
			difference(){
				translate(v=[0,0,top_h-lip_h+100/2]) cube(size=[ext_l_holder+2,ext_b_holder+2,100],center=true);
				translate(v=[0,0,0]) rounded_cuboid_2_5(ext_l_holder-2*wall_t_holder+2*lip_t,ext_b_holder-2*wall_t_holder+2*lip_t,top_h,ext_r_holder-wall_t_holder/2,curve_f_holder,true);//lips
			}
			translate(v=[0,0,ext_h_holder/2]) rotate(a=[180,0,0]){
				 if(north_cutout==1){
					if(n_cutout_c==1){
					#	translate(v=[+cutout_wall_thickness+ext_l_holder/2,n_cutout_t-wall_t_holder,n_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=n_cutout_r,h=n_cutout_h,center=false); //circular cutout on "North" end	
					}else{
					#	translate(v=[+cutout_wall_thickness+ext_l_holder/2-wall_t_holder,n_cutout_t,n_cutout_e-int_h_holder/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (n_cutout_l,n_cutout_b,n_cutout_h,n_cutout_r,curve_f_holder,center=true); //uUSB cutout on "North" end
					}
				}if(south_cutout==1){
					if(s_cutout_c==1){
					#	rotate(a=[0,0,180]) translate(v=[+cutout_wall_thickness+ext_l_holder/2,s_cutout_t,s_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=s_cutout_r,h=s_cutout_h,center=false); //circular cutout on "South" end	
					}else{
			 	#		translate(v=[-ext_l_holder/2+wall_t_holder-cutout_wall_thickness-wall_t_holder,-s_cutout_t,s_cutout_e+base_t_holder-s_cutout_l/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (s_cutout_l,s_cutout_b,s_cutout_h,s_cutout_r,curve_f_holder,center=true); //uUSB cutout on "south" end
					}
				}if(south_cutout2==1){
					if(s_cutout_c2==1){
					#	rotate(a=[0,0,180]) translate(v=[+cutout_wall_thickness+ext_l_holder/2,s_cutout_t2,s_cutout_e2-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=s_cutout_r2,h=s_cutout_h2,center=false); //circular cutout on "South" end	
					}else{
					#	translate(v=[-ext_l_holder/2+wall_t_holder-cutout_wall_thickness-wall_t_holder,-s_cutout_t2,s_cutout_e2+base_t_holder-s_cutout_l2/2]) rotate(a=[0,90,0])rounded_cuboid_2_5 (s_cutout_l2,s_cutout_b2,s_cutout_h2,s_cutout_r2,curve_f_holder,center=true); //uSD cutout on "south" end
					}
				}if(east_cutout==1){
					if(e_cutout_c==1){
					#	rotate(a=[0,0,-90]) translate(v=[+cutout_wall_thickness+ext_b_holder/2,e_cutout_t,e_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=e_cutout_r,h=e_cutout_h,center=false); //circular cutout on "East" end	
					}else{
					#	rotate(a=[0,0,90])translate(v=[-ext_b_holder/2+wall_t_holder-cutout_wall_thickness,-e_cutout_t,e_cutout_e+base_t_holder-e_cutout_l/2]) rotate(a=[0,90,180])rounded_cuboid_2_5 (e_cutout_l,e_cutout_b,e_cutout_h,e_cutout_r,curve_f_holder,center=true); //uUSB cutout on "East" end
					}
				}if(west_cutout==1){
					if(w_cutout_c==1){
					#	rotate(a=[0,0,90]) translate(v=[+cutout_wall_thickness+ext_b_holder/2,w_cutout_t,w_cutout_e-int_h_holder/2]) rotate(a=[0,-90,0]) cylinder (r=w_cutout_r,h=w_cutout_h,center=false); //circular cutout on "West" end	
					}else{
						#rotate(a=[0,0,-90])translate(v=[-ext_b_holder/2+wall_t_holder-cutout_wall_thickness,-w_cutout_t,w_cutout_e+base_t_holder-w_cutout_l/2]) rotate(a=[0,90,180])rounded_cuboid_2_5 (w_cutout_l,w_cutout_b,w_cutout_h,w_cutout_r,curve_f_holder,center=true); //uUSB cutout on "West" end
					}
				}if(top_cutout==1){
					if(t_cutout_c==1){
						#mirror (v=[0,0,1]) translate(v=[t_cutout_x,t_cutout_y,-ext_h_holder/2+cutout_base_thickness]) cylinder (r=t_cutout_r,h=t_cutout_h,center=false); //circular cutout on "Top" end	
					}else{
						#rotate(a=[0,0,0])translate(v=[t_cutout_x,t_cutout_y,ext_h_holder/2-cutout_base_thickness]) rotate(a=[0,180,0])rounded_cuboid_2_5 (t_cutout_l,t_cutout_b,t_cutout_h,t_cutout_r,curve_f_holder,center=true); //uUSB cutout on "Top" end
					}
				}
			}
		}
	}
}



//*********************Modules*******************

module cylindrical_posts (post_l,post_b,post_h_outer,post_r_outer,post_h_inner,post_r_inner,post_x_offset,post_y_offset,post_type){
	//make 4 cylindrical support posts
	//place cylinders post_h_outer tall with radius post_r_outer at each vertex of rectangle defined by post_l & post_b
	//add (1) or subtract (0) depending on post_type cylinders post_h_inner tall with radius post_r_inner at (1) or from (0) cylinders
	//translate this shape by post_x_offset post_y_offset
	//I might need to add a_bit to this in various places for manifoldness

	for ( holder_x = [-(post_l/2), (post_l/2)]) {
		for ( holder_y = [-(post_b/2), (post_b/2)]) {
			if (post_type==0){ //a screw hole type post
				difference(){
					translate (v=[holder_x+post_x_offset, holder_y+post_y_offset,0]) cylinder(h = post_h_outer+a_bit, r = post_r_outer, center=false);//main body of post
					translate (v=[holder_x+post_x_offset, holder_y+post_y_offset, (post_h_outer-post_h_inner)+a_bit]) cylinder(h = post_h_inner+a_bit, r = post_r_inner, center=false);//screw hole of post
				}
			}

			else{//(post_type==1){ //a nub type post
				union(){
					translate (v=[holder_x+post_x_offset, holder_y+post_y_offset,0]) cylinder(h = post_h_outer+a_bit, r = post_r_outer, center=false);//main body of post
					translate (v=[holder_x+post_x_offset, holder_y+post_y_offset, post_h_outer]) cylinder(h = post_h_inner, r = post_r_inner, center=false);//nub of post
				}
			}
		}
	}
}

module cube_cone_cylinder_minkowski(size_x,size_y,size_z,size_r, size_z_flat, num_sides,overlap,center_loc){ 
	if(center_loc==1){
		translate(v=[(size_r+(overlap/2))-size_x/2,(size_r+(overlap/2))-size_y/2,-size_z/2]){
			minkowski(){
				cube([size_x-2*size_r,size_y-2*size_r,(size_z_flat)/2]);
				union(){
					cylinder(r1=size_r+(overlap/2),r2=size_r-(overlap/2),h=size_z-size_z_flat, center=false, $fn=num_sides*4);
					cylinder(r=size_r-(overlap/2),h=size_z-(size_z_flat/2), center=false, $fn=num_sides*4);
				}
			}
		}
	}if(center_loc==0){
		translate(v=[size_r+(overlap/2),size_r+(overlap/2),0]){
			minkowski(){
				cube([size_x-2*size_r,size_y-2*size_r,(size_z_flat)/2]);
				union(){
					cylinder(r1=size_r+(overlap/2),r2=size_r-(overlap/2),h=size_z-size_z_flat, center=false, $fn=num_sides*4);
					cylinder(r=size_r-(overlap/2),h=size_z-(size_z_flat/2), center=false, $fn=num_sides*4);
				}
			}
		}
	}if(center_loc==2){
		translate(v=[size_r,size_r,0]){
			minkowski(){
				cube([size_x-2*size_r,size_y-2*size_r,(size_z_flat)/2]);
				union(){
					cylinder(r1=size_r+(overlap/2),r2=size_r-(overlap/2),h=size_z-size_z_flat, center=false, $fn=num_sides*4);
					cylinder(r=size_r-(overlap/2),h=size_z-(size_z_flat/2), center=false, $fn=num_sides*4);
				}
			}
		}
	}
}

module basic_shape(ext_l, ext_b, ext_h, ext_r, curve_f, wall_t, lip_t, lip_h,lip_p){
	difference(){
		 //The Biggest of the rounded cuboid, the external dimensions
		rounded_cuboid(ext_l, ext_b, ext_h, ext_r, curve_f);

		//Smaller of the two rounded cuboids removed to make the inside hollow, the internal dimensions
		translate (v = [0, 0, wall_t+0.1]) rounded_cuboid(ext_l-wall_t*2, ext_b-wall_t*2, ext_h+0.2, ext_r-wall_t, curve_f);
		if (lip_p==0){//A flat rounded cuboid removed to make the lip for a click fit type box
			if(simple_lip==1) translate (v = [0, 0, ext_h/2-lip_h/2-0.1])  rounded_cuboid(ext_l-lip_t*2, ext_b-lip_t*2, lip_h+0.2, ext_r-lip_t, curve_f);
			if(simple_lip==0) translate (v = [0, 0, ext_h/2-lip_h/2-0.1]) cube_cone_cylinder_minkowski(ext_l-lip_t*2,ext_b-lip_t*2,lip_h+0.3,ext_r-lip_t, (lip_h+0.2)/2, curve_f,0.2,1);

		}
		if (lip_p==1){
			//A flat rounded cuboid removed to make the lip for a click fit type box
			translate (v = [0, 0, ext_h/2-lip_h/2+0.1]) 

			difference(){
				cube(size = [ext_l+0.2, ext_b+0.2, lip_h], center=true);
				if(simple_lip==1) rounded_cuboid(ext_l-lip_t*2, ext_b-lip_t*2, lip_h+0.2, ext_r-lip_t, curve_f);
				if(simple_lip==0) mirror(v=[0,0,1]) cube_cone_cylinder_minkowski(ext_l-lip_t*2,ext_b-lip_t*2,lip_h+0.2,ext_r-lip_t, (lip_h+0.2)/2, curve_f,0.2,1);

			}
		}
	}
}


module hollow_rounded_cuboid_2_5(n_tot_l, n_tot_b, n_tot_h, n_tot_r, n_tot_s, n_wall_t,n_center=true){
//	$fn=n_tot_s*4;
	difference(){
		rounded_cuboid_2_5(n_tot_l, n_tot_b, n_tot_h, n_tot_r, n_tot_s,n_center);
		if(n_center==true){
			translate(v=[0,0,-0.1])rounded_cuboid_2_5(n_tot_l-2*n_wall_t, n_tot_b-2*n_wall_t, n_tot_h+2*0.1, n_tot_r-n_wall_t, n_tot_s,n_center);
		}else{
			translate(v=[n_wall_t,n_wall_t,-0.1])rounded_cuboid_2_5(n_tot_l-2*n_wall_t, n_tot_b-2*n_wall_t, n_tot_h+2*0.1, n_tot_r-n_wall_t, n_tot_s,n_center);
		}
	}
}

module rounded_cuboid_2_5(m_tot_l, m_tot_b, m_tot_h, m_tot_r, m_tot_s,m_center=true){
	//$fn=m_tot_s*4;
	if(m_center==true){
		translate(v=[m_tot_r-(m_tot_l/2),m_tot_r-(m_tot_b/2),0]){
			minkowski(){
				cube([m_tot_l-2*m_tot_r,m_tot_b-2*m_tot_r,m_tot_h/2]);
				cylinder(r=m_tot_r,h=m_tot_h/2,centre=true);
			}
		}
	}else{
		translate(v=[m_tot_r,m_tot_r,0]){
			minkowski(){
				cube([m_tot_l-2*m_tot_r,m_tot_b-2*m_tot_r,m_tot_h/2]);
				cylinder(r=m_tot_r,h=m_tot_h/2,centre=true);
			}
		}
	}
}

module mouse_ears (ear_offset_x, ear_offset_y, ear_height, ear_diameter){
	translate(v=[-ear_offset_x/2, -ear_offset_y/2,0]) cylinder(r=ear_diameter/2, h=ear_height, centre=true);
	translate(v=[-ear_offset_x/2, ear_offset_y/2,0]) cylinder(r=ear_diameter/2, h=ear_height, centre=true);
	translate(v=[ear_offset_x/2, -ear_offset_y/2, 0]) cylinder(r=ear_diameter/2, h=ear_height, centre=true);
	translate(v=[ear_offset_x/2, ear_offset_y/2,0]) cylinder(r=ear_diameter/2, h=ear_height, centre=true);
}