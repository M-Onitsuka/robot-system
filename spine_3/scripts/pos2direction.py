#! /usr/bin/env python
import numpy as np
import roslib
import rospy
from std_msgs.msg import String
from spine_3.msg import center_pos
from spine_3.msg import send_py

mode = 0 #mode 0:train mode, 1:practice mode

def callback(data):
    global mode
    rospy.loginfo(rospy.get_caller_id()+"%s",data.comment)
    print "its okay?(push any key)"
    okay = raw_input()
    if mode == 0:
        print "input pitch"
        pitch = input()
        print "input yaw"
        yaw = input()

        rpy_data = send_py()
        #rpy_data.header = data.header
        rpy_data.comment = "roll, pitch and yaw"
        rpy_data.rpy.x = 0
        rpy_data.rpy.y = pitch
        rpy_data.rpy.z = yaw
        pub.publish(rpy_data)

        print "input dif_x"
        dif_x = raw_input()
        print "input dif_y"
        dif_y = raw_input()

        X_ = np.load('input_data.npy')
        X_ = np.vstack([X_, np.array([data.pos.x,data.pos.y,dif_x,dif_y,1])])
        np.save('input_data.npy',X_)

        Y_ = np.load('output_data.npy')
        Y_ = np.vstack([Y_, np.array([pitch,yaw])])
        np.save('output_data.npy',Y_)

    if mode == 1:
        X_ = np.load('input_data.npy').T
        Y_ = np.load('output_data.npy')
        XTY = np.dot(X_.T,Y_)
        XTX = np.dot(X_.T,X_)
        W = np.dot(np.linalg.inv(XTX),XTY)
        X_s = np.array([data.pos.x,data.pos.y,0,0,1])
        A = np.dot(W,X_s)

        rpy_data = send_py()
        rpy_data.comment = "final answer"
        rpy_data.rpy.x = 0
        rpy_data.rpy.y = pitch
        rpy_data.rpy.z = yaw
        pub.publish(rpy_data)
        rospy.sleep(1.0)

def pos2derection():
    rospy.Subscriber("center_pos",center_pos,callback)
    rospy.spin()

if __name__ == '__main__':
    #pub = rospy.Publisher('Send_py_data',send_py, queue_size=1)
    pub = rospy.Publisher('Send_py_data',send_py)
    rospy.init_node('pos2derection',anonymous=False)
    pos2derection()
