(local log (require :log))
(local robots (require :robots))
(local probes (require :probes))
(local iis (require :iis))

(fn score->outcome
  [score]
  (if (>= score 85)
    :DENY
    (>= score 70)
    :WARN
    :ALLOW))

(fn deny-user-agent [{: user-agent}]
  (if (= user-agent "-")
    [100 user-agent "Missing user agent"]
    (let [compare (string.lower user-agent)]
      (accumulate [o [0 nil nil] _ ua (ipairs robots.ai-robots)]
        (if (string.find compare (string.lower ua))
          [100 user-agent "User Agent contains known AI Scraper"]
          o)))))

(fn deny-probe [{: uri}]
  (let [compare (string.lower uri)]
    (accumulate [o [0 nil nil] _ probe-uri (ipairs probes)]
      (if (not (= 100 (. o 1)))
        (if (string.find compare (string.lower probe-uri))
          [100 uri "URI contains known likely probe path"]
          o)
        o))))

(local rules [deny-user-agent deny-probe])

(fn check [line]
  (log.info "Checking line " line "\n")
  (let [parts (iis.parse line)]
    (set parts.score 0)
    (set parts.rule :ALLOW)
    (set parts.reason "")

    (accumulate [triggered parts _ f (ipairs rules)]
      (if (not (= triggered.rule :DENY))
        (let [applied (f parts)
              outcome (score->outcome (. applied 1))]
          (if (= outcome :DENY)
            (do 
              (set parts.score (. applied 1))
              (set parts.rule outcome)
              (set parts.reason (. applied 3))
              parts)
            triggered))
        triggered))))

{: check : score->outcome}
