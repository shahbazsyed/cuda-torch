FROM nvidia/cuda:7.5-cudnn4-devel
MAINTAINER Edgar Y. Walker <edgar.walker@gmail.com>

# Install dependencies
RUN apt-get update \
    && apt-get install -y curl libzmq3-dev libssl-dev\
       python-zmq ipython-notebook \
       git cmake software-properties-common \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Torch
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash \
    && git clone https://github.com/torch/distro.git ~/torch --recursive \
    && cd ~/torch; ./install.sh

# Configure iTorch notebook
ADD ipython_notebook_config.py /root/.ipython/profile_torch/ipython_notebook_config.py
EXPOSE 8888
VOLUME /notebooks
WORKDIR /notebooks

# Setup environment variables to access installed softwares
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' 
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

# Install torch CUDA extension
RUN luarocks install cutorch && \
    luarocks install cunn
                                                   
# Setup iTorch notebook by default
CMD ["/bin/bash", "-c", "itorch notebook"]
