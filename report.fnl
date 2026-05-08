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
                             (let [{: client-ip} c]
                               (if (. agg client-ip)
                                 (do (tset agg client-ip "request-count" (+ (or (. agg client-ip "request-count") 0) 1))
                                   agg)
                                 (do 
                                   (tset agg client-ip c)
                                   agg))))

              checks (icollect [_ v (pairs checks-by-ip)] v)]
          (table.sort checks  (fn [a b]
                                (if (= a.score b.score)
                                  (> a.request-count b.request-count)
                                  (> a.score b.score))))
          checks))
    _ (do (log.error path " cannot be opened")
        {})))

{: build }
