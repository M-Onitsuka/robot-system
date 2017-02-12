(load "package://spine_3/euslisp/spine-3-interface.l")
(setq *ri* (instance spine-3-interface :init))

(setq av (send *ri* :state :potentio-vector))
(print (list 'current-position av))
(print 'send-angle-vector)
(send *ri* :angle-vector (v+ av #f(90 0 0)) 10000)
(print 'wait-for-motion)
(send *ri* :wait-interpolation)

(print 'send-angle-vector)
(send *ri* :angle-vector (v+ av #f(0 0 0)) 10000)
(print 'wait-5-sec)
(unix:sleep 5)
(print 'send-angle-vector-again)
(send *ri* :angle-vector (v+ av #f(90 0 0)) 10000)


