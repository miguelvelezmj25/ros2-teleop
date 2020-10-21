from time import sleep

import rclpy

from geometry_msgs.msg import Twist

def main(args=None):
    print('Starting autoteleop')

    rclpy.init(args=args)
    node = rclpy.create_node('autoteleop')
    publisher = node.create_publisher(Twist, 'cmd_vel', 10)

    dir = 1.0
    while True:
        twist = Twist()
        twist.linear.x = 0.2 * dir
        twist.linear.y = 0.0
        twist.linear.z = 0.0
        publisher.publish(twist)
        dir = dir * -1.0
        sleep(3)  

    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
