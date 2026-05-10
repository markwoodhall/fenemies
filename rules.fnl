(local log (require :log))
(local robots (require :robots))
(local iis (require :iis))

(fn deny-user-agent [v]
  (let [compare (string.lower v)]
    (accumulate [o [0 nil nil] _ ua (ipairs robots)]
      (if (not (= 100 (. o 1)))
          (if (string.find compare (string.lower ua))
              [100 ua "User Agent contains known AI Scraper"]
              o)
          o))))

(fn check [line]
  (log.info "Checking line " line "\n")
  (let [parts (iis.parse line)
        {: client-ip : user-agent } parts
        [score ua reason] (deny-user-agent user-agent)
        rule (if (>= score 100)
                 :DENY
                 :ALLOW)]
    (when (= rule :DENY)
      (set parts.ai-agent ua)
      (set parts.reason reason))
    (set parts.score score)
    (set parts.rule rule)
    (log.info (. parts :rule) " " client-ip " " user-agent "\n")
    parts))

{: check }
