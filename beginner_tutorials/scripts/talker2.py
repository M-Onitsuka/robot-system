#!/usr/bin/env python

import roslib
import rospy
from std_msgs.msg import String
from beginner_tutorials.msg import Hello

i = 0

def talker2():
    global i
    pub = rospy.Publisher('chatter2', Hello)
    rospy.init_node('talker2')
    while not rospy.is_shutdown():
        str = "hello world %s %d"%(rospy.get_time(),i)
        rospy.loginfo(str)
        hello = Hello();
        hello.hello = "world"
        hello.pos.x = 0
        hello.pos.y = 1
        hello.pos.z = 2
        pub.publish(hello)
        rospy.sleep(1.0)
        i = i+1

if __name__ == '__main__':
    try:
        talker2()

    except rospy.ROSInterruptException: pass
