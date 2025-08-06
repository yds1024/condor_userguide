#include <cuda_runtime.h>
#include <iostream>
#include <stdio.h>

__global__ void sleep_kernel(float seconds) {
    unsigned long long start_clock = clock64();
    unsigned long long wait_clocks = (unsigned long long)(seconds * 1.0e9);

    while (clock64() - start_clock < wait_clocks) {
        // do nothing, just wait
    }
}

int main(int argc, char const *argv[]) {
	float sleep_time = atof(argv[1]); // in seconds
    std::cout << "Sleeping for " << sleep_time / 60 << " minutes..." << std::endl;
  
    sleep_kernel<<<1, 1>>>(sleep_time);
    cudaDeviceSynchronize();

    std::cout << "Woke up after " << sleep_time / 60 << " minutes!" << std::endl;
    return 0;
}