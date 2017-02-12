#!/usr/bin/env python

import roslib
import rospy
from std_msgs.msg import String

i = 0

def talker():
    global i
    pub = rospy.Publisher('chatter', String)
    rospy.init_node('talker')
    while not rospy.is_shutdown():
        str = "hello world %s %d"%(rospy.get_time(),i)
        rospy.loginfo(str)
        pub.publish(String(str))
        rospy.sleep(1.0)
        i = i+1

if __name__ == '__main__':
    try:
        talker()

    except rospy.ROSInterruptException: pass
