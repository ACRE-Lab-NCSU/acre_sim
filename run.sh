#!/bin/bash
xhost +local:docker
docker run -it --rm \
    --network host \
    -e DISPLAY=$DISPLAY \
    -e XDG_RUNTIME_DIR=/tmp/runtime-root \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --device /dev/dri \
    -e "CYCLONEDDS_URI=<CycloneDDS><Domain><General><Interfaces><NetworkInterface name=\"lo\"/></Interfaces></General></Domain></CycloneDDS>" \
    -e ROS_DOMAIN_ID=1 \
    -v $(pwd):/workspace:z \
    acre_sim