(local log (require :log))
(local rules (require :rules))

(fn group-by [col k]
  (accumulate [agg {} 
               _ c (ipairs col)]
    (let [{: time-taken : seconds } c
          k-val (. c k)]
      (if (. agg k-val)
        (do
          (tset agg k-val "request-count" (+ (or (. agg k-val "request-count") 0) 1))
          (tset agg k-val "total-time" (+ (or (. agg k-val "total-time") 0) time-taken))
          (when (or (not (. agg k-val "start-time"))
                    (> (. agg k-val "start-time") seconds))
            (tset agg k-val "start-time" seconds))
          (when (or (not (. agg k-val "end-time"))
                    (< (. agg k-val "end-time") seconds))
            (tset agg k-val "end-time" seconds))

          (when (and (. agg k-val "start-time")
                     (. agg k-val "end-time"))
            (tset agg k-val "wall-time" (- (. agg k-val "end-time")
                                               (. agg k-val "start-time"))))
          agg)
        (do
          (tset agg k-val c)
          (tset agg k-val "request-count" 1)
          (tset agg k-val "total-time" time-taken)
          (tset agg k-val "start-time" seconds)
          (tset agg k-val "end-time" seconds)
          agg)))))

(fn score-sort [col]
  (table.sort col (fn [a b]
                     (if (or (= a.score b.score))
                       (> a.request-count b.request-count)
                       (> a.score b.score))))
  col)

(fn build [path]
  (case (io.open path)
    f (with-open [f f]
        (let [lines (f:read :*all)
              lines (icollect [l (string.gmatch lines "[^\n]+")] l)
              checks (icollect [_ line (ipairs lines)]
                       (when (not (string.find line "^#"))
                         (rules.check line)))
              checks-by-ip (icollect [_ v (pairs (group-by checks :client-ip ))] v)
              checks-by-uri (icollect [_ v (pairs (group-by checks :uri ))] v)]
          {:checks-by-ip (score-sort checks-by-ip)
           :checks-by-uri (score-sort checks-by-uri)}))
    _ (do (log.error path " cannot be opened")
        {})))

{: build }
