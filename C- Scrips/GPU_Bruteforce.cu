/*
CUDA code for GPU optimization of camera placement problem
With support of 2-coverage Region of Interest
Author : Vegard Tveit
Date : 17.04.2018
Comment : The user has to specify: 

	- Number of sensors to be placed
	- Number of possible combinations(nchoosek)
	- Modify UNISIZE 
	- Number of datapoints
	- Number of possible placement points
	- Number of possible pan angles
	- "subsets.txt", "annotations.txt" and "combinations.txt" 

*/
// Initial Setup
#include <iostream>
#include <string>
#include <fstream>
#include <vector>

#include <new>
#define UNISIZE 9084
#include <cmath>
#include <algorithm>
#include <numeric>
#include <functional>
#include <fstream>
__global__ void mykernel(int* annotations, int* devarr, bool* subs, int* sum, unsigned long len, unsigned long nsubs, unsigned long usize, int roisum)
{		
	// Kernel function to run on GPU
	// Defining variables (stored in each kernel)
	unsigned long th_id = blockIdx.x * blockDim.x + threadIdx.x;		// The id of the current thread	 	
	int barr[9084] = {0}; //Array for storing coverage
	int totsum = 0; // Sum of covered points	
	int count_roi = 0; 
	int penalty = 0; 
	int alpha = 4000; 
	
	int ct = 0; 
	if(th_id < len){
		for(unsigned long i = 0; i < nsubs; i++)
		{		
			int ind = devarr[th_id*nsubs + i];
			for(unsigned long j = 0; j < usize; j++)
			{
				if(subs[ind*usize + j]){
					barr[j] += 1; 
				
				}
			}
		
		}			
		for(int i = 0 ; i < usize ; i++){
			if(barr[i] >= annotations[i]){
				totsum += 1; 
				if(annotations[i] == 2){
					count_roi += 1; 
				}
			}
		}
		if(count_roi > 0 && count_roi < roisum){
			penalty = alpha*(roisum/count_roi); 
		}
		if(count_roi == 0){
			penalty = alpha*roisum; 
		}
		
		sum[th_id] = totsum - penalty;			
	}else sum[th_id] = 0; 
	
}

void readfromtxt(){

	//int num_sensors = 1; 
	//int ncombs = 210; 
	int num_sensors = 5; 
	int ncombs = 1.5e8;
	 
	//unsigned long num_sensors = 3; 
	//unsigned long ncombs = 1521520;
	
	//unsigned long num_sensors = 4; 
	//unsigned long ncombs = 78738660;

	unsigned long ndp = 9084; 
	unsigned long campos = 83; 
	unsigned long numpans = 3; 
	
	std::cout << "num combs : " << ncombs << std::endl; 
	
	// Dynamically allocate arrays on CPU
	int* array = (int*)malloc(ncombs*num_sensors*sizeof(int)); 	
	bool* subs_array = (bool*)malloc(ndp*campos*numpans*sizeof(bool*));
	int* annot_array = (int*)malloc(ndp*sizeof(int));
	
	//Load subsets from txt file and store in 1D array
	std::ifstream subsfile("Subsets_4cam.txt"); 
	double b;
	unsigned long col_s = 0; 
	while (subsfile >> b)
	{
		subs_array[col_s] = (bool) b;
		
		col_s +=1; 		
		
	}
	for(int i = 0; i < 15 ; i++){
		std::cout << subs_array[i] << std::endl;
	}
	std::cout << std::endl << std::endl  <<std::endl; 
	std::cout << col_s << " is col_s" << std::endl; 
	// Store combinations array in a 1D array
	std::ifstream myfile("combtests_1.txt"); 
	double bb; 
	unsigned long col = 0; 
	std::cout << "Hei!" << std::endl; 
	while (myfile >> bb)
   	 {	
		array[col] = (int) bb;		
		if(col < 10) std::cout << bb << std::endl; 
		col += 1;  
   	 }	
	
			
	std::cout << col << " is col" << std::endl; 
	// Store annotations in a 1D array
	// The annotation of a point describes whether it is
	// a ROI, obstacle or normal data point
	std::ifstream annotfile("Annotations.txt"); 
	double an;
	unsigned long col2 = 0; 

	while (annotfile >> an)
    {
		annot_array[col2] =(int) an;		
		col2 += 1; 
    }	
	
	// Make annotation array (to be used inside kernel)
	int* init_cov = (int*)malloc(ndp*sizeof(int)); 
	//int init_cov[ndp];
	int c = 0; 
	for(int i = 0 ; i < ndp ; i++){
		if(annot_array[i] == 2){
			c += 1; 
			init_cov[i] = 2; 
		}else{
			init_cov[i] = 1; 
		}
	}
	std::cout << "Num of roi dp: " << c << std::endl; 
	

	//GPU variables
	unsigned long n_threads_per_block = 1024; 
	unsigned long n_blocks = (ncombs + n_threads_per_block - 1)/n_threads_per_block;
	
	std::cout << "Number of blocks :" << n_blocks << std::endl; 
	unsigned long data_n = n_blocks*n_threads_per_block; // Total number of available threads
	
	//Vectorize array for GPU calculations
	unsigned long chop_combs;	
	chop_combs = ncombs; 
	
	std::cout << "No. of available threads: " <<  data_n << std::endl; 
	std::cout << "Number of used threads : " << chop_combs << std::endl;
		
	size_t i_datasize = chop_combs*sizeof(int); 
	size_t array_datas = chop_combs*num_sensors*sizeof(int); 
	size_t bool_subs_size = ndp*numpans*campos*sizeof(bool); 
	size_t annot_size = ndp*sizeof(int);
	
	std::cout << "i_datasize [bytes] : " << i_datasize <<  std::endl; 
	
	// Allocate CPU Memory
	int* sum_host = new int[chop_combs]; 
	
	std:: cout << "Array size : " << array_datas <<" and subs size " << bool_subs_size << std::endl; 
	
	// Allocate GPU Memory
	int* annot_dev;
	bool* subs_dev; 
	int* sum_dev; 
	int* array_dev;
	
	cudaMalloc(&subs_dev,bool_subs_size);
	cudaMalloc(&array_dev, array_datas);
	cudaMalloc(&sum_dev,i_datasize); 
	cudaMalloc(&annot_dev,annot_size); 
	
	// Copy host (CPU) arrays to device (GPU) arrays
	cudaMemcpy(subs_dev, subs_array, bool_subs_size, cudaMemcpyHostToDevice);	
	cudaMemcpy(sum_dev, sum_host, i_datasize, cudaMemcpyHostToDevice);	
	cudaMemcpy(array_dev, array, array_datas, cudaMemcpyHostToDevice);	
	cudaMemcpy(annot_dev,init_cov,annot_size,cudaMemcpyHostToDevice);
	
	// Run "mykernel" function on GPU threads with gpu timing
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);	
	cudaEventRecord(start);
	
	mykernel <<< n_blocks,n_threads_per_block >>> (annot_dev,array_dev,subs_dev,sum_dev,chop_combs,num_sensors,ndp,c);
	
	cudaDeviceSynchronize();
	cudaEventRecord(stop);	
	cudaEventSynchronize(stop);
	
	float milliseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);

	printf("The elapsed time for kernel execution was %.2f ms\n", milliseconds);
	// Copy results back to cpu memory
	cudaMemcpy(sum_host, sum_dev, i_datasize, cudaMemcpyDeviceToHost);
	
	// Post process	
	int max = 0; 
	unsigned long  ind = 0; 
	for (unsigned long  i = 0; i < chop_combs ; i++){
		if(sum_host[i] > max){
			max = sum_host[i];
			ind = i; 
		} 
	}
	std::cout << "Max val : " << max << std::endl; 	
	printf("Highest coverage value at index %lu. \n",ind); 
	std::cout << "The index represents camera index: ";  
	for(int m = 0; m < num_sensors ; m++){
		
		printf("%i ", array[ind*num_sensors + m]);
	}
	std::cout << std::endl; 
	
	//Free allocated memory on CPU and GPU
	cudaFree(subs_dev);
	cudaFree(sum_dev); 
	cudaFree(array_dev);
	delete[] sum_host; 
	free(array); 
	free(subs_array);
	
}


