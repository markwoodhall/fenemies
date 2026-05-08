(local log (require :log))
(local rules (require :rules))

(fn build [path]
  (case (io.open path)
    f (with-open [f f]
        (let [lines (f:read :*all)
              lines (icollect [l (string.gmatch lines "[^\n]+")] l)
              checks (icollect [_ line (ipairs lines)]
                       (when (not (string.find line "^#"))
                         (rules.check line)))
              checks-by-ip (accumulate [agg {} _ c (ipairs checks)]
                             (let [{: client-ip : time-taken : seconds } c]
                               (if (. agg client-ip)
                                   (do
                                     (tset agg client-ip "request-count" (+ (or (. agg client-ip "request-count") 0) 1))
                                     (tset agg client-ip "total-time" (+ (or (. agg client-ip "total-time") 0) time-taken))
                                     (when (or (not (. agg client-ip "start-time"))
                                               (> (. agg client-ip "start-time") seconds))
                                       (tset agg client-ip "start-time" seconds))
                                     (when (or (not (. agg client-ip "end-time"))
                                               (< (. agg client-ip "end-time") seconds))
                                       (tset agg client-ip "end-time" seconds))

                                     (when (and (. agg client-ip "start-time")
                                                (. agg client-ip "end-time"))
                                       (tset agg client-ip "wall-time" (- (. agg client-ip "end-time")
                                                                          (. agg client-ip "start-time"))))
                                     agg)
                                   (do
                                     (tset agg client-ip c)
                                     (tset agg client-ip "request-count" 1)
                                     (tset agg client-ip "total-time" time-taken)
                                     (tset agg client-ip "start-time" seconds)
                                     (tset agg client-ip "end-time" seconds)
                                     agg))))

              checks (icollect [_ v (pairs checks-by-ip)] v)]
          (table.sort checks  (fn [a b]
                                (if (or (= a.score b.score))
                                  (> a.request-count b.request-count)
                                  (> a.score b.score))))
          checks))
    _ (do (log.error path " cannot be opened")
        {})))

{: build }
