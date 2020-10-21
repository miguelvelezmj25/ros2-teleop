#!/bin/bash
set -e

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "/root/turtlebot3_ws/install/setup.bash"
source "/root/autoteleop/install/setup.bash"
exec "$@"

