OUTPUT = x.run
CC = nvcc
FLAGS = -O3 -gencode arch=compute_86,code=sm_86
DEBUG = 
GCCOPTIONS =-Wno-deprecated-gpu-targets
CFLAGS=

default: program

program:
	$(CC) $(FLAGS) $(CFLAGS) $(DEBUG) $(GCCOPTIONS) $(OBJECTS) test.cu -o $(OUTPUT)

clean:
	-rm -f $(OUTPUT)