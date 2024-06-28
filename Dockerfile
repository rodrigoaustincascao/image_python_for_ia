# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1

# Create and set the working directory
WORKDIR /workspace

# Install required packages and build dependencies
RUN apt-get update \
    && apt install --assume-yes --no-install-recommends software-properties-common \
    build-essential \
    zsh \
    htop \
    unzip \
    wget \
    gpg \
    git \
    curl \
    sudo \
    glibc-source \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# # Instalando NVIDIA toolkit
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
RUN apt-get update
RUN apt-get install -y nvidia-container-toolkit

# RUN  wget https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda-repo-debian11-12-5-local_12.5.0-555.42.02-1_amd64.deb \
#     && dpkg -i cuda-repo-debian11-12-5-local_12.5.0-555.42.02-1_amd64.deb \
#     && cp /var/cuda-repo-debian11-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
#     && add-apt-repository contrib -y \
#     && apt upgrade --assume-yes \
#     && apt-get -y install cuda-toolkit-12-5 \
#     && rm cuda-repo-debian11-12-5-local_12.5.0-555.42.02-1_amd64.deb \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# Comando para localizar o local do CUDA 
# ldconfig -p| grep libcuda
# RUN export LD_LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

# Create a non-root user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID


RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# OhMyZsh (better than "bash")
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 

# Install VS Code extensions for Python development
RUN pip install --upgrade pip setuptools wheel


# Copy any requirements.txt for pre-installing dependencies
COPY requirements.txt .
RUN pip install -r /workspace/requirements.txt

# Ensure the working directory is owned by the non-root user
RUN sudo chown -R $USERNAME:$USERNAME /workspace

# Expose the application port (if necessary)
EXPOSE 8000

CMD [ "python" ]