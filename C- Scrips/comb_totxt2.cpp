// C++ Code for combinatorial placement of n pre-defined cameras for a given
// JSON file with visibility model with variable pan angle
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
#include <algorithm>
#include <chrono>
#include <numeric>
#include <functional>
#include <fstream>


// Typedefs and namespace 
using namespace json11;
using std::string;
typedef std::vector<Json> array;
typedef std::vector< std::vector<int> > matrix_int;
typedef std::vector<int> array_int; 
typedef std::vector<bool> array_bool;
typedef std::vector< std::vector<bool> > matrix_bool;
typedef std::vector< std::vector<double> > matrix_double;
typedef std::chrono::high_resolution_clock Clock;

// Initialize function callers
array_int evalu(int lpans, int valueo);
//double factorial(double n);
long long int nchoosek(int N, int K);
matrix_int comb(int  N, int  K);

// Function to run in main loop
static void parse_from_stdin() {
// Initialize strings, ints etc
string buf;
string line;
int i = 0;
double val_annot = 0;
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
        if(annot[k0] == 1){
                cot0 = cot0 + 1;
        }
}

// Determine all obstacle coordinates and collect into double arrays
int coto = 0;
double obstx[cot0];
double obsty[cot0];
double obstz[cot0];

for(int ko = 0 ; ko < json[0].array_items().size() ; ko++){
	if(annot[ko] == 1){
		double obstxx = datax[ko];
		double obstyy = datay[ko];
		double obstzz = dataz[ko];

		obstx[coto] = obstxx;
		obsty[coto] = obstyy;
		obstz[coto] = obstzz;
		coto = coto + 1;
	}
}

// Initialize constants 
const double pi = 3.1415926535897;
const int numcams = 4; 
const int numpan = 3;
double pan; 
bool b; 



// USER DEFINED array of possible pan angles 
const double  panarray[numpan] = {0,pi/4,-3*pi/4};
// Pan and tilt angles should be defined in [-pi,pi]


// Sensor parameters 
double fov = 45*(pi/180);		// Half of the field of view
double tilt = pi/6;			// Tilt (Rot Z of the camera)
double range = 9;			// The range of the camera
double x,y,z;


// Determine coverage for all positions and all poses
int combco = numpan*kcz;
auto t1 = Clock::now();
matrix_bool outmat(combco,std::vector<bool>(ky));
int iteration = 0; 
for(int j_k = 0; j_k < kcz ; j_k++){

	// Set current camera 1 position
	x = camposx[j_k];
	y = -6;
	z = camposz[j_k];

	for(int pancount = 0 ; pancount < numpan ; pancount++){

		pan = panarray[pancount]; // Set pan angle

		for(int i = 0; i < ky ; i++){

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
							b=true;
							if((pan - fov) <= o_xya && o_xya <= (pan + fov) ){
								if(std::abs(xya - o_xya) <  thr){
									if( ((tilt - fov) <= o_xza) && (o_xza <= (tilt + fov)) ){
										if(std::abs(xza - o_xza) < thr){
											if(L > o_L){
												b = false;
											}
										}
									}
								}
							}
						}
					}
					else{
					b = false;
					}
				}
				else{
					b = false;
				}
			}
			else{
				b = false;
			}

		outmat[iteration][i] = b; 	
		}
		iteration = iteration + 1; 
	}
}

	// Determine number of combinations 
	unsigned long long comnum = nchoosek(combco,numcams); 
std::cout << "The comnum is : " << comnum << std::endl; 
int chopmax = 2.9e8; 
	// Array to store combinations 
	matrix_int combarr(chopmax , std::vector<int>(numcams)); 
std::cout << "Hi!" << std::endl; 
	combarr = comb((int)combco,(int)numcams);
	std::cout << combarr[1][1] << std::endl; 
	
	// Write all binary subsets to "subsets.txt"
	std::ofstream subsets; 
	subsets.open("Subsets_1.txt"); 
	for(int i = 0; i < iteration; i++){
		for(int j = 0; j < ky ; j++){
			subsets << outmat[i][j] << " "; 
		}
		subsets << "\n";	
	}
	
	// Write all annotations to "annotations.txt" 
	std::ofstream an; 
	an.open("Annotations_1.txt"); 
	for(int i = 0; i < ky; i++){
			an << annot[i] << " "; 
		}
	
	
	// Write all combinations to "combinations.txt"
	std::ofstream myfile; 
	myfile.open("Combinations_1.txt");
	for(int j = 0; j < comnum ; j++){
		for(int i = 0; i < numcams ; i++){
		
			myfile << combarr[j][i] << " "; 
		}
		myfile << "\n"; 
	}
	myfile.close(); 
}	

// Main execution loop
int main(int argc, char **argv) {
    if (argc == 2 && argv[1] == string("--stdin")) {
        parse_from_stdin();
        return 0;
    }
}
//--------------------------------------------------------------------------------------------------------
// FUNCTIONS 

/*
// Function for determining factorials
double factorial(double n)
{
	if(n>1)
	{
		return n*factorial(n-1);
	}
	else
	{
		return 1; 
	}

}
*/
// Function for determining matrix of all combinations 
matrix_int comb(int  N, int  K)
{
    long long int fi = nchoosek(N,K); 
    matrix_int  out((int)fi + 1,std::vector<int>(K));		
	int c2; 	
    std::string bitmask(K, 1); // K leading 1's	
    bitmask.resize(N, 0); // N-K trailing 0's
   // int testi = 1; 	
	int count = 0;
    // print integers and permute bitmask
    do {
		c2 = 0;
        for (int i = 0; i < N; ++i) // [0..N-1] integers
        {
            if (bitmask[i]){		
		 out[count][c2] = i;		 
		 c2 = c2 + 1;
		}
        }
	count = count + 1;
    } while (std::prev_permutation(bitmask.begin(), bitmask.end()));
    return out;
}

// Function for determining the binomial coefficient 
long long int nchoosek(int N, int K)
{
std::string bitmask(K, 1); // K leading 1's
    bitmask.resize(N, 0); // N-K trailing 0's
	long long int counter = 0; 
    do {
		counter = counter + 1;
    } while (std::prev_permutation(bitmask.begin(), bitmask.end()));

	return counter;
}	
// Function for evaluating the camera and pan indexes
array_int evalu(int lpans, int valueo)
{
	array_int outarray(2); 				//Initialize array
	double ic = (double)valueo;			 
	double pc = floor(ic/lpans);		// Determine the current camera index
	int panx = valueo - (int)pc*lpans;	// Determine the current pan angle index
	int camx = (int)pc; 
	
	// Return results
	outarray[0] = panx; 
	outarray[1] = camx; 
	return outarray; 
}
