wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/1/cuda_10.2.1_linux.run
sudo sh
echo "Running driver installation script"
sh ./cuda_10.2.89_440.33.01_linux.run
echo "Running patch installation script"
sh ./cuda_10.2.1_linux.run
