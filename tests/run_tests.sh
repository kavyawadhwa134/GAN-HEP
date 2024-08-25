nvidia-smi

echo "building hello"
nvcc -o hello hello.cu
echo "building vadd"
nvcc -o vadd vadd.cu

echo "building cudnn_test"
g++ -c cudnn_test.cc -o cudnn_test.o -I/srv/conda/envs/notebook/lib/python3.11/site-packages/nvidia/cuda_runtime/include/ -I/srv/conda/envs/notebook/targets/x86_64-linux/include/ -I/srv/conda/envs/notebook/lib/python3.11/site-packages/nvidia/cudnn/include/
nvcc -ccbin g++ -m64 -o cudnn_test cudnn_test.o -lcublasLt -lcudart -lcublas -lcudnn -lstdc++ -lm -L/srv/conda/envs/notebook/lib

echo "running hello"
./hello
echo "running vadd"
./vadd
echo "running cudnn_test"
./cudnn_test

echo "done"
