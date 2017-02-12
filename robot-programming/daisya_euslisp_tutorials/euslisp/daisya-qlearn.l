;;
;; ��ư��֤�Ȥä���ϩ�򶯲��ؽ���Ȥä�æ�Ф��륵��ץ�
;;    2009/12/02 written by nakanish
;;
(load "daisya.l")
(load "maze.l")
(load "qlearn.l")

;;��ϩ���Ҥ��̤����� .. x���㳲ʪ��-������ʤ��Ȥ�����s���������ȡ�g��������
(setq *map* (list
	     "xxxxxxxxxxxxxxxx"
	     "x--------------x"
	     "x-s--x---------x"
	     "x------xxx-----x"
	     "x----x---------x"
	     "x-----xx--xxx--x"
	     "x-----x-x-x----x"
	     "x-----x--xx--g-x"
	     "x--------------x"
	     "xxxxxxxxxxxxxxxx"
	     ))
(defvar *m* nil)               ;;��ϩ��graphɽ��
(defvar *maze-column-num* nil) ;;��ϩ�β���
(defvar *maze-row-num* nil)    ;;��ϩ�νĿ�
(setq *maze-length* 400)       ;;��ϩ����������
(setq *maze-height* 150)       ;;��ϩ�ι⤵������
;;
;; *m*�˥��åȤ��줿�Ͽޤκ��������ܥåȤΥ������Ȱ���(map��s)�ؤ�����
(defvar *maze* nil)
(warn "(maze-init)~%")
(defvar *goal*)

(defun maze-init
  (&optional (map *map*))
  (let (start)
    ;;���̤��ʤ����ɽ��
    (when (not (boundp '*irtviewer*))
      (setq *irtviewer* (make-irtviewer)))

    ;; *m*, *maze-column-num*, *maze-row-num*��map��������
    (setq *m* (map2graph map))
    (setq *maze-column-num* (- (length (elt map 0)) 2))
    (setq *maze-row-num* (- (length map) 2))           

    ;;��ϩ��ǥ����������
    (setq *maze* (make-maze *m*
			    :row-num *maze-row-num*
			    :column-num *maze-column-num*
			    :maze-length *maze-length*
			    :maze-height *maze-height*))

    ;;��֥�ǥ����������
    (when (not (boundp '*daisya*))
      (setq *daisya* (instance daisyaclass :init)))
  
    ;;�Ӥϼ���������޾���
    (send *daisya* :angle-vector #f(0 0 0 80 -20 -90 0 0))
  
    ;;map����start���ֹ���������
    (setq start (get-start-index map))
    ;;��֥�ǥ�򥹥����Ȱ��֤˥��åȤ���
    (send *daisya* :locate
	  (generate-coords-from-nodenum start
					:column-num *maze-column-num*
					:maze-length *maze-length*) 
	  :world)

    ;;qlearn��map�˻ؼ����줿goal�ΰ��֤��֤������򤪤�
    (setq *goal* (make-cylinder (* *maze-length* 0.4) *maze-height*))
    (setf (get *goal* :face-color) :red)
    (send *goal* :locate
	  (generate-coords-from-nodenum (get-goal-index map)
					:column-num *maze-column-num*
					:maze-length *maze-length*)
	  :world)

    ;;���̤˥�ǥ��ɽ��
    (objects (list *maze* *daisya* *goal*))
  ))

;;��ϩ��Ȥ��ؽ���Ԥ�
(warn "(maze-learn)~%")
(defvar *search-env* nil)    ;;�ؽ��Τ���δĶ����饹
(defvar *search-agent* nil)  ;;�ؽ���Ԥ�����������ȥ��饹
(defun maze-learn
  (&key (map *map*) (debug nil))
  (setq *search-env* (instance mdp-search-environment :init map))
  (setq *search-agent*
	;;�ؽ������ˤ�äơ����̤꤫����ߤ���
	;;(instance mdp-dyna-search-agent :init *search-env*)
	(instance mdp-search-agent :init *search-env*)
	;;(instance smdp-search-agent :init *search-env*)
	)
  ;;�ؽ���Ԥ�
  (learn *search-agent* "qlearn.dat" :debug debug)
  )

;;�ؽ���̤�Ȥä���ϩ��Ȥ��ǥ�(����������Ȱ��֤����Ǥ��뤫��)
(warn "(maze-demo)~%")
(defun maze-demo
  ()
  ;;agent���ʤ���гؽ�������
  (when (not *search-agent*) (maze-learn))
  ;;
  ;;�ؽ���������������Ȥν��Ϥ˱����ơ�1���ƥåפ�����֤��ư������
  (let* (start
	 (tgcount (*search-env* . ngoal))              ;;�Ķ��Υ�������
	 (tcount 0) pos
	 )
    ;;������֤ذ�ư
    (setq start (get-start-index *map*))
    (move-daisya 
     (generate-coords-from-nodenum start :column-num (get *maze* :column-num)
					 :maze-length (get *maze* :maze-length))
     :view nil)
    ;;
    (send *irtviewer* :draw-objects)
    (unix:usleep 500) ;;�ٷ�
    ;;
    ;;agent�ΰ��֤��ѹ�
    ;;(send *search-env* :set-agent-pos index)

    ;;
    ;;�⤦���٥����뤹��ޤ� send a :policy-proc��Ԥ�
    (while (= tgcount (*search-env* . ngoal))
      ;;1step�ʤ��
      (send *search-agent* :policy-proc)
      ;;���ߤξ������
      (setq pos
	    (index2num (send *search-env* :state2xy (send *search-env* :state))
		       *maze-column-num*))
      
      ;;�򤱤��start����äƤ��ޤ��Τǡ�goal�ˤ�������
      (when (not (= tgcount (*search-env* . ngoal))) (setq pos (get-goal-index *map*)))
      ;;
      ;;�����ޤǰ�ư����
      (move-daisya
       (generate-coords-from-nodenum pos
				     :column-num (get *maze* :column-num)
				     :maze-length (get *maze* :maze-length))
       :view t)
      )
    ))

#|*****************************************

qlearn�Τ������ϩ���Ҥ˽񤭴����뤿���ɬ�פʴؿ������

*******************************************|#
;;map����graph����������(���꤬x�ǰϤޤ�Ƥ���Ȳ���)
(defun map2graph
  (map)
  (let (ret width height path
	    index check-index-list
	)
    ;;x��ξ�����ɤˣ��Ĥ��Ĥ���Ȥ���
    (setq height (- (length map) 2))
    (setq width (- (length (car map)) 2))
    ;;
    ;;x,y�����ˤ���Ƥ������������ɸ������Ƥ���
    (dotimes (y height)
      (dotimes (x width)
	(setq index (list (1+ x) (1+ y)))
	(setq check-index-list
	      (list
	       (list (1- (elt index 0)) (elt index 1)) ;;��
	       (list (1+ (elt index 0)) (elt index 1)) ;;��
	       (list (elt index 0) (1- (elt index 1))) ;;��
	       (list (elt index 0) (1+ (elt index 1))) ;;��
	       ))
	;;�������Ȥ��㳲ʪ����ʤ��ä���
	(when (not (= (elt (elt map (elt index 1)) (elt index 0)) #\x))
	  (dolist (check-index check-index-list)
	    ;;�����褬�㳲ʪ����ʤ��ä���
	    (when (not (= (elt (elt map (elt check-index 1)) (elt check-index 0)) #\x))
	      (setq path (list (index2num index width) (index2num check-index width)))
	      ;;path���ɲä��ߤǤʤ��ä���,�ɲ�
	      (when (not (member path ret :test #'myset=))
		(push path ret))))
	  )))
    (nreverse ret)
    ))
;;index�����ɸ�ֹ���֤�(���夬1������width*height)
(defun index2num
  (index width)
  (+ 1 
     (1- (floor (elt index 0)))
     (* (1- (floor (elt index 1))) width)))

;;map����start��index���������
(defun get-start-index
  (map)
  (get-symbol-index map #\s))
;;map����goal��index���������
(defun get-goal-index
  (map)
  (get-symbol-index map #\g))
;;goal��index���������
(defun get-symbol-index
  (map sym)
  (let* ((height (- (length map) 2))
	 (width (- (length (car map)) 2))
	 index
	 )
    (dotimes (y height)
      (dotimes (x width)
	(setq index (list (1+ x) (1+ y)))
	;;index��ʸ����s���ä���,index���֤�
	(when (= (elt (elt map (elt index 1)) (elt index 0)) sym)
	  (return-from get-symbol-index (index2num index width)))))
    ))
;; ����Ȥ��������������֤�(�Ƶ���Ȥ�ʤ���������Ƥߤ�)
;;  (myset= (list 1 2) (list 2 1))
(defun myset=
  (a b)
  (let ((flag t))
    (cond
     ((not (= (length a) (length b)))
      (setq flag nil))
     (t
      (dolist (c a)
	(when (not (member c b))
	  (setq flag nil)
	  (return-from nil)))))
    flag))
    

;; ��֤��ɸ�ذ�ư������ʥ��˥᡼�����)
;;   ��ž����ư��ɬ�פʾ��Ϥ��Τ褦��
;; �ǽ�ϰ�ư��angle-vector��ȤäƤ����Τ�����ɡ���ư����������
;;   base-x,y,z�����ˤ����Ƥ��äƤ��ޤ�orz
(defun move-daisya
  (c         ;;c�Ϻ�ɸ #f(0 0 0)�ߤ����ʤ��
   &key   
   (view t)               ;;���褹��
   (ticktime 50)          ;;������ε٤߻���[msec]
   (interpolation-num 10) ;;�䴰��
   )
  (let* ((current-pos (send *daisya* :worldpos))
	 ;;���ߤΥ��ܥåȤθ���
	 (current-angle (rad2deg 
			 (atan (aref (matrix-column (send *daisya* :worldrot) 0) 1)
			       (aref (matrix-column (send *daisya* :worldrot) 0) 0))))
	 (diff-vector (v- c current-pos))
	 ;;��ɸ�Υ��ܥåȤθ���
	 (goal-angle (rad2deg (atan (aref diff-vector 1) (aref diff-vector 0))))
	 diff-angle
	 )
    (cond
     (view ;;current-vector -> goal-vector�ޤ��䴰����ɽ��
      (setq diff-vector (scale (/ 1.0 interpolation-num) diff-vector))
      (setq diff-angle (/ (- goal-angle current-angle) interpolation-num))
      (dotimes (i interpolation-num)
	(send *daisya* :translate diff-vector :world)   ;;�¹԰�ư
	(send *daisya* :rotate (deg2rad diff-angle) :z) ;;��ž
	(send *irtviewer* :draw-objects)                ;;����
	(unix:usleep (* 1000 ticktime)))
      )
     (t
      ;;���֤򤢤碌��
      (send *daisya* :translate diff-vector :world) ;;�¹԰�ư
      ;;��ž�򤢤碌��
      (send *daisya* :rotate (deg2rad (- goal-angle current-angle)) :z) ;;��ž
      ))
    ))