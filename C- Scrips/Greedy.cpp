// C++ Code for iterative placement of n pre-defined cameras for a given
//JSON file with visibility model with variable pan angle
// Author : Vegard Tveit
// Date : 25.02.2018
// Comment : This code uses the json11 library found at :
// https://github.com/dropbox/json11

// Initial Setup
#include <iostream>
#include "json11.hpp"
#include <string>
#include <fstream>
#include <vector>
#include <cmath>
#include <chrono>


using namespace json11;
using std::string;
typedef std::vector<Json> array;
typedef std::chrono::high_resolution_clock Clock;
static void parse_from_stdin() {
// Initialize strings, ints etc
string buf;
string line;
int i = 0;

//double val = 0;
double val_annot = 0;
//double outval = 0;
int j = 0;
long long int ii; //gpu thread index (to be used later)
string err,mystr;
std::string mystrings;
std::string teststring;
std::string annotations;

while (std::getline(std::cin, line)) {
	buf += line + "\n";
}
// Pass data from json file
auto json = Json::parse(buf, err);

/*
Input Json Array Index :
	0 : Annotations
        1 : Camera Points (x)
        2 : Camera Points (z)
	3 : Data Points (x)
	4 : Data Points (y)
	5 : Data Points (z)
	6 : Camera Parameters
*/
/* Store JSON data into arrays
	annot : Double array of annotations
	datax : Double array of data points (x)
	datay : Double array of data points (y)
	dataz : Double array of data points (z)

	Note: Camera poisions - Fixed in y -direction at -6

	camx : Camera positions (x)
	camz : Camera poisitons (z)
*/
// Store annotations to annot
double annot[json[0].array_items().size()];
for(auto &value :json[0].array_items()){

	annotations = value.dump();
        std::string::size_type sz;
        val_annot = stod(annotations,&sz);
        annot[j] = val_annot;
	j = j + 1;
}
// Store data points (x) to datax
double datax[json[3].array_items().size()];
int kx = 0;
for(auto &valuex :json[3].array_items()){
	std::string dataxs;
	double valx;
        dataxs = valuex.dump();
        std::string::size_type sz;
        valx = stod(dataxs,&sz);
        datax[kx] = valx;
        kx = kx + 1;
}

// Store data points (y) to datay
double datay[json[4].array_items().size()];
int ky = 0;
for(auto &valuey :json[4].array_items()){
        std::string datays;
        double valy;
        datays = valuey.dump();
        std::string::size_type sz;
        valy = stod(datays,&sz);
        datay[ky] = valy;
        ky = ky + 1;
}
// Store data points (z) to dataz
double dataz[json[5].array_items().size()];
int kz = 0;
for(auto &valuez :json[5].array_items()){
	std::string datazs;
	double valz;
	datazs = valuez.dump();
	std::string::size_type sz;
	valz = stod(datazs,&sz);
	dataz[kz] = valz;
	kz = kz + 1;
}

// Store camera positions (x) to camposx
double camposx[json[1].array_items().size()];
int kcx = 0;
for(auto &value_cx :json[1].array_items()){
        std::string camposxs;
        double camx;
        camposxs = value_cx.dump();
        std::string::size_type sz;
        camx = stod(camposxs,&sz);
        camposx[kcx] = camx;
        kcx = kcx + 1;
}
// Store camera positions (z) to camposz
double camposz[json[2].array_items().size()];
int kcz = 0;
for(auto &value_cz :json[2].array_items()){
        std::string camposzs;
        double camz;
        camposzs = value_cz.dump();
        std::string::size_type sz;
        camz = stod(camposzs,&sz);
        camposz[kcz] = camz;
        kcz = kcz + 1;
}

// Determine number of obstacle points
int cot0 = 0;
for(int k0 = 0 ; k0 < json[0].array_items().size() ; k0++){
        if(annot[k0] != 0){
                cot0 = cot0 + 1;
        }
}


std::cout << "number of datapoints: " << ky <<std::endl; 

// Determine all obstacle coordinates and collect into double arrays
int coto = 0;
double obstx[cot0];
double obsty[cot0];
double obstz[cot0];

for(int ko = 0 ; ko < json[0].array_items().size() ; ko++){
	if(annot[ko] == 1){
		double obstxx = datax[coto];
		double obstyy = datay[coto];
		double obstzz = dataz[coto];

		obstx[coto] = obstxx;
		obsty[coto] = obstyy;
		obstz[coto] = obstzz;
		coto = coto + 1;
	}
}
std::cout << "Number of obstacles : " << coto <<std::endl;
std::cout << "number of cameras : " << kcx << std::endl; 
// Test sensor placement
// Initialize camera parameters
int numcams = 10;
// Pan and tilt angles should be defined in [-pi,pi]
const double pi = 3.1415926535897;
double fov = 45*(pi/180);		// Half of the field of view
double tilt = 1*pi/6;			// Tilt (Rot Z of the camera)
double range = 9;			// The range of the camera
double x,y,z;

double myxval,myzval;
// Initialize loop help variables
double max = 0;
int num = 0;
bool b;


// Initialize arrays and loop help variables
double pan;
int numpan = 7;
double mypval[numcams];
double camxpos[numcams];
double camzpos[numcams];
int coverage[kz];
int final_coverage[kz];
int ff_coverage[kz];
//double panarr[numpan] ={0};
double panarr[numpan] = {0,pi/4,pi/2,3*pi/4,-pi/4,-pi/2,-3*pi/4};


auto t1 = Clock::now();
// Loop through number of cameras
for(int camcount = 0 ; camcount < numcams ; camcount++){
	if(camcount > 0){
		for(int covcount = 0 ; covcount < ky ; covcount++){
			if(final_coverage[covcount] == 1){
				ff_coverage[covcount] = 1;
			}
		}
	}
	max = 0; // Reset max variable for current camer
	for(int j_k = 0 ; j_k < kcz; j_k++) {

		// Set current camera 1 position
		x = camposx[j_k];
		y = -6;
		z = camposz[j_k];
		// Initialize sum variable

		for(int pancount = 0 ; pancount < numpan ; pancount++){

			int sum = 0;	// Reset sum variable for current pan angle
			pan = panarr[pancount]; // Set pan angle

			for(int i = 0; i < ky ; i++){

				// Only compute visibility and coverage is point is not yet covered
				if(ff_coverage[i] != 1){

					// Set current data point set
					double xp = datax[i];
					double yp = dataz[i];
					double zp = datay[i];
					// Determine distance from sensor to data point
					double L = std::sqrt(std::pow(xp-x,2) + std::pow(zp-z,2) + std::pow(yp-y,2));
					// Determine angle between sensor and data point (XY plane)
					double xya = std::atan2((zp-z),(xp-x));
					// Determine angle between sensor and data point (XZ plane)
					double xza = std::atan2((yp-y),L);
					// Determine if point is seen by camera
					if(L < range){
						if( (pan - fov) <= xya && xya <= (pan+ fov) ){
							if( ((tilt - fov) <= xza) && (xza <= (tilt + fov)) ){
								// Determine visibility
								for(int vk = 0 ;vk <  coto ; vk++){
									double xobs = obstx[vk];
									double yobs = obsty[vk];
									double zobs = obstz[vk];
									double o_L = std::sqrt(std::pow(xobs-x,2) + std::pow(zobs-z,2) + std::pow(yobs-y,2));
									double o_xya = std::atan2((zobs-z),(xobs-x));
									double thr = 0.25;
									double o_xza = std::atan2((yobs-y),o_L);

									// Is obstacle point within sensing range
									b=1;
									if((pan - fov) <= o_xya && o_xya <= (pan + fov) ){
										if(std::abs(xya - o_xya) <  thr){
											if( ((tilt - fov) <= o_xza) && (o_xza <= (tilt + fov)) ){
												if(std::abs(xza - o_xza) < thr){
													if(L > o_L){
														b = 0;
													}
												}
											}
										}
									}
								}
							}
							else{
							b = 0;
							}
						}
						else{
							b = 0;
						}
					}
					else{
						b = 0;
					}
					if(b==1){
						coverage[i] = 1;
					}
					else{
						coverage[i] = 0;
					}
					// Sum for the current camera position increases by one if the above conditions are fulfilled
					sum = sum +  b;
				}
			}

			// If current pan config is better than previously for the current camera
			// Save pan config as best
			if(sum > max){
				max = sum;
				num = j_k;

				// Loop through coverage array
				for(int covi = 0 ; covi < ky ; covi++){
					final_coverage[covi] = coverage[covi];
				}
				myxval = camposx[num];
				myzval = camposz[num];
				mypval[camcount] = pan;
				camzpos[camcount] = myzval;
				camxpos[camcount] = myxval;
			}

		}
	}
}
auto t2 = Clock::now();
std::cout << "Elapsed Time: " 
<< std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count()
<< " milliseconds" << std::endl; 


/*
for(int testi = 0; testi < ky ; testi++){
	double mytestval1 = final_coverage[testi];
}
*/

// Output results
for(int ijj = 0; ijj < numcams ; ijj++){
	double myvalue = camxpos[ijj];
	double myzvalue = camzpos[ijj];
	double mypanvalue = mypval[ijj];
	std::cout << std::endl;
	std::cout << "Camera x : " << myvalue <<   std::endl;
	std::cout << "Camera z : " << myzvalue << std::endl;
	std::cout << "Pan : " << mypanvalue << std::endl;
}
double fsum = 0; 
for(int ickk = 0; ickk < ky ; ickk++){
	if(ff_coverage[ickk] == 1){
	fsum = fsum + 1;
	}else if(final_coverage[ickk] == 1){
	fsum = fsum + 1;
	}
}
double fperc = (fsum/ky) * 100; 

std::cout << "Percentage coverage " << fperc <<  " " << cot0  <<  std::endl; 
std::cout << "Covered data points " << fsum << std::endl;
}
// Main execution loop
int main(int argc, char **argv) {
    if (argc == 2 && argv[1] == string("--stdin")) {
        parse_from_stdin();
        return 0;
    }
}
