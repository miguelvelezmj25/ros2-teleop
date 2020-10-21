FROM osrf/ros:dashing-desktop

ENV DEBIAN_FRONTEND noninteractive
ENV TURTLEBOT3_MODEL burger
#ENV ROS_SECURITY_ROOT_DIRECTORY /security_keys
#ENV ROS_SECURITY_ENABLE true
#ENV ROS_SECURITY_STRATEGY Enforce

COPY vnc /
RUN true

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      apt-utils \
      bzip2 \
      cmake \
      build-essential \
      ca-certificates \
      curl \
      gcc \
      g++ \
      less \
      mercurial \
      python-pip \
      software-properties-common \
      tmux \
      vim \
      wget

# install vncserver
RUN apt-get update \
 && apt-get install -y \
      supervisor \
      vnc4server \
      xfce4 \
      xfce4-goodies \
      xfce4-terminal \
      xserver-xorg-core \
      xterm \
      xvfb \
      x11vnc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir ~/.vnc \
 && /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd"
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

# install turtlebot ROS2 dependent packages
RUN apt-get update \
  && apt install -y \
      python3-colcon-common-extensions
RUN curl -sSL http://get.gazebosim.org | sh
RUN apt remove -y \
      gazebo11 \
      libgazebo11-dev
RUN apt install -y \
      gazebo9 \
      libgazebo9-dev \
      ros-dashing-gazebo-ros-pkgs

# install turtlebot3 packages
RUN mkdir -p ~/turtlebot3_ws/src \
  && cd ~/turtlebot3_ws \
  && wget https://raw.githubusercontent.com/ROBOTIS-GIT/turtlebot3/ros2/turtlebot3.repos \
  && vcs import src < turtlebot3.repos \
  && . /opt/ros/dashing/setup.sh \
  && colcon build --symlink-install

# Save Bash Command for Setup
RUN echo 'source ~/turtlebot3_ws/install/setup.bash' >> ~/.bashrc
RUN echo 'export ROS_DOMAIN_ID=30 #TURTLEBOT3' >> ~/.bashrc
RUN echo 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/turtlebot3_ws/src/turtlebot3/turtlebot3_simulations/turtlebot3_gazebo/models' >> ~/.bash

COPY launch root/launch
RUN true
COPY sros /
RUN true
COPY autoteleop root/autoteleop
RUN true \
  && cd ~/autoteleop \
  && colcon build

COPY ros_entrypoint.sh /
RUN true

