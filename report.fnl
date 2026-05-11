(local log (require :log))
(local rules (require :rules))

(fn group-by [col k]
  (accumulate [agg {} 
               _ c (pairs col)]
    (let [{: time-taken : seconds : score : rule } c
          k-val (. c k)]
      (if (. agg k-val)
        (do
          (let [request-count (+ (or (. agg k-val "request-count") 0) 1)
                total-score (+ (or (. agg k-val "total-score") 0) score)
                avg-score (/ total-score request-count)
                total-time (+ (or (. agg k-val "total-time") 0) time-taken)]
            (tset agg k-val "request-count" request-count)
            (tset agg k-val "total-score" total-score)
            (tset agg k-val "avg-score" avg-score)
            (tset agg k-val "total-time" total-time)
            (tset agg k-val "total-rule" (rules.score->outcome avg-score))

            (when (or (not (. agg k-val "start-time"))
                      (> (. agg k-val "start-time") seconds))
              (tset agg k-val "start-time" seconds))

            (when (or (not (. agg k-val "end-time"))
                      (< (. agg k-val "end-time") seconds))
              (tset agg k-val "end-time" seconds))

            (when (and (. agg k-val "start-time")
                       (. agg k-val "end-time"))
              (tset agg k-val "wall-time" (- (. agg k-val "end-time")
                                             (. agg k-val "start-time")))))
          agg)
        (do
          (tset agg k-val (collect [k v (pairs c)] k v))
          (tset agg k-val "request-count" 1)
          (tset agg k-val "total-score" score)
          (tset agg k-val "total-rule" rule)
          (tset agg k-val "avg-score" score)
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
              checks-by-ip (icollect [_ v (pairs (group-by checks :client-ip))] v)
              checks-by-uri (icollect [_ v (pairs (group-by checks :uri))] v)
              checks-by-user-agent (icollect [_ v (pairs (group-by checks :user-agent))] v)
              checks-by-cidr-24 (icollect [_ v (pairs (group-by checks :cidr-24))] v)
              checks-by-cidr-16 (icollect [_ v (pairs (group-by checks :cidr-16))] v)]
          {:checks-by-ip (score-sort checks-by-ip)
           :checks-by-uri (score-sort checks-by-uri)
           :checks-by-user-agent (score-sort checks-by-user-agent)
           :checks-by-cidr-24 (score-sort checks-by-cidr-24)
           :checks-by-cidr-16 (score-sort checks-by-cidr-16)}))
    _ (do (log.error path " cannot be opened")
        {})))

{: build }
